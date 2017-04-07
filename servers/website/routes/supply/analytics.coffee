LOAD_ERROR = {
  success: false
  error: "Please try again in 1 minute"
}

moment = require "moment"

module.exports.get = (req, res, next)->
  redis_key = "publisher.#{req.publisher.key}.analytics"

  LIBS.redis.get(redis_key).then (analytics)->
    if analytics?     
      try
        analytics = JSON.parse analytics
        end = moment(analytics.cachedAt)
        
        if moment().diff(end, "hours") < 1
          return analytics.response
  
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
    }).then (analytics)->    
      if analytics.devices_chart.result?
        for device in analytics.devices_chart.result.result
          if device["user_agent.parsed.device.family"] == "Other"
            device["user_agent.parsed.device.family"] = "Desktop"
      
      
      if analytics.protection_count.result? and analytics.view_count.result?
        analytics.protection_count.result.result = Math.min 100, Math.floor (analytics.protection_count.result.result/analytics.view_count.result.result) * 100
        analytics.protection_count.result.result = Number analytics.protection_count.result.result.toFixed(2)
      
      else
        analytics.protection_count = LOAD_ERROR
      
      
      if analytics.fill_count.result? and analytics.impression_count.result?
        analytics.fill_count.result.result = Math.min 100, Math.floor (analytics.impression_count.result.result/analytics.fill_count.result.result) * 100
        analytics.fill_count.result.result = Number analytics.fill_count.result.result.toFixed(2)
      
      else
        analytics.fill_count = LOAD_ERROR
      
      
      if analytics.click_count.result? and analytics.impression_count.result?
        analytics.ctr_count.result = {
          query: analytics.protection_count.result.query
          result: Number ((analytics.click_count.result.result/analytics.impression_count.result.result) * 100).toFixed(2)
        }
      
      else
        analytics.ctr_count = LOAD_ERROR
        
      LIBS.redis.set(redis_key, JSON.stringify({
        cachedAt: new Date()
        response: analytics
      }))
      return analytics
  
    
  .then (analytics)->
    res.json(analytics)
    
  .catch next
