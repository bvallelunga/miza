module.exports.get = (req, res, next)->
  client = LIBS.keen.scopedAnalysis(req.publisher.config.keen)
  
  query = (operation, query)->
    query.event_collection = "ads.event"
    query.timeframe = req.query.timeframe or "this_1_month"
    client.query(operation, query).then (response)->    
      return {
        success: true
        result: response
      }
  
  Promise.props({
    impressions_chart: query "count", {
      interval: "daily"
      group_by: [ "type" ]
      filters: [{
        "operator": "in",
        "property_name": "type",
        "property_value": [
          "click",
          "impression"
        ]
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
    fill_count: query "count", {
      filters: [{
        "operator": "eq"
        "property_name": "type"
        "property_value": "request"
      }]
    }
    protection_count:  query "count", {
      filters: [{
        "operator": "eq"
        "property_name": "type"
        "property_value": "ping"
      }, {
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }]
    }
    devices_chart: query "count", {
      group_by: [
        "user_agent.parsed.os.family"
      ]
      filters: [{
        "operator": "eq",
        "property_name": "type",
        "property_value": "ping"
      }, {
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }]
    }
    browsers_chart: query "count", {
      group_by: [
        "user_agent.parsed.browser.family"
      ]
      filters: [{
        "operator": "eq",
        "property_name": "type",
        "property_value": "ping"
      }, {
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }]
    }
    ctr_count: {
      success: true
      result: {}
    }
  }).then (props)->
    props.protection_count.result.result = Math.min 100, Math.floor props.protection_count.result.result/props.view_count.result.result * 100
    props.fill_count.result.result = Math.min 100, Math.floor props.impression_count.result.result/props.fill_count.result.result * 100
    props.ctr_count.result = {
      query: props.protection_count.result.query
      result: Math.floor props.click_count.result.result/props.impression_count.result.result * 100
    }
  
    res.json(props)
    
  .catch next
