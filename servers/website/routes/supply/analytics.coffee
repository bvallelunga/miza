LOAD_ERROR = {
  success: false
  error: "Please try again in 1 minute"
}

module.exports.get = (req, res, next)->
  client = LIBS.keen.scopedAnalysis(req.publisher.config.keen)
  
  query = (operation, collection, query)->
    Promise.resolve().then ->    
      if typeof collection == "object"
        return Promise.map collection, (type)->
          query.event_collection = "ads.event.#{type}"
          query.timeframe = req.query.timeframe or "this_1_month"
          return client.query(operation, query)
        
        .then (responses)->        
          return {
            success: true
            result: responses
          }
      
      query.event_collection = "ads.event.#{collection}"
      query.timeframe = req.query.timeframe or "this_1_month"
      client.query(operation, query).then (response)->    
        return {
          success: true
          result: response
        }
    
    .catch (error)->
      LIBS.bugsnag.notify error
    
      return LOAD_ERROR
      
  
  Promise.props({
    impressions_chart: query "count", ["impression", "click"], {
      interval: "daily"
    }
    impression_count: query "count", "impression", {}
    click_count: query "count", "click", {}
    view_count: query "count", "ping", {}
    fill_count: query "count", "request", {}
    protection_count:  query "count", "ping", {
      filters: [{
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }]
    }
    os_chart: query "count", "ping", {
      group_by: [
        "user_agent.parsed.os.family"
      ]
      filters: [{
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }]
    }
    devices_chart: query "count", "ping", {
      group_by: [
        "user_agent.parsed.device.family"
      ]
      filters: [{
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }]
    }
    countries_chart: query "count", "ping", {
      group_by: [
        "location.country"
      ]
      filters: [{
        "operator": "eq"
        "property_name": "protected"
        "property_value": true
      }, {
        "operator": "ne"
        "property_name": "location.country"
        "property_value": null
      }]
    }
    browsers_chart: query "count", "ping", {
      group_by: [
        "user_agent.parsed.browser.family"
      ]
      filters: [{
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
    if props.devices_chart.result?
      for device in props.devices_chart.result.result
        if device["user_agent.parsed.device.family"] == "Other"
          device["user_agent.parsed.device.family"] = "Desktop"
    
    
    if props.protection_count.result? and props.view_count.result?
      props.protection_count.result.result = Math.min 100, Math.floor (props.protection_count.result.result/props.view_count.result.result) * 100
    
    else
      props.protection_count = LOAD_ERROR
    
    
    if props.fill_count.result? and props.impression_count.result?
      props.fill_count.result.result = Math.min 100, Math.floor (props.impression_count.result.result/props.fill_count.result.result) * 100
    
    else
      props.fill_count = LOAD_ERROR
    
    
    if props.click_count.result? and props.impression_count.result?
      props.ctr_count.result = {
        query: props.protection_count.result.query
        result: Math.floor (props.click_count.result.result/props.impression_count.result.result) * 100
      }
    
    else
      props.ctr_count = LOAD_ERROR
    
    res.json(props)
    
  .catch next
