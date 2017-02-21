module.exports.get = (req, res, next)->
  client = LIBS.keen.KeenAnalysis(req.publisher.config.keen)
  
  query = (operation, query)->
    query.event_collection = "ads.event"
    query.timeframe = req.query.timeframe or "this_1_month"
    client.query(operation, query).then (response)->    
      return {
        success: true
        result: response
      }
    
    .catch (error)->
      return {
        success: false
        error: "No data available"
      }
  
  Promise.props({
    impressions_chart: query "count", {
      interval: "daily"
      filters: [{
        "operator": "eq"
        "property_name": "type"
        "property_value": "impression"
      }]
    }
    impression_count: query "count", {
      filters: [{
        "operator": "eq"
        "property_name": "type"
        "property_value": "impression"
      }]
    }
    click_count: query "count", {
      filters: [{
        "operator": "eq"
        "property_name": "type"
        "property_value": "click"
      }]
    }
    view_count: query "count", {
      filters: [{
        "operator": "eq"
        "property_name": "type"
        "property_value": "ping"
      }]
    }
    devices_chart: query "count", {
      group_by: [
        "user_agent.parsed.os.family"
      ]
      filters: [{
        "operator": "eq",
        "property_name": "type",
        "property_value": "impression"
      }]
    }
    browsers_chart: query "count", {
      group_by: [
        "user_agent.parsed.browser.family"
      ]
      filters: [{
        "operator": "eq",
        "property_name": "type",
        "property_value": "impression"
      }]
    }
  }).then (props)->
    res.json(props)
    
  .catch next