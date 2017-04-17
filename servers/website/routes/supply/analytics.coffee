LOAD_ERROR = {
  success: false
  error: "Please try again in 1 minute"
}

moment = require "moment"

module.exports.get = (req, res, next)->  
  query = (query_name)->
    LIBS.keen.fetchDataset(query_name, {
      index_by: req.publisher.key
      timeframe: "this_month"
    }).catch (error)->
      #LIBS.bugsnag.notify error
      console.log error
      return LOAD_ERROR
  
  Promise.props({
    impressions_chart: Promise.all([
      query "publisher-impression-chart"
      query "publisher-click-chart"
    ])
    impression_count: query "publisher-impression-count"
    click_count: query "publisher-click-count"
    view_count: query "publisher-ping-count"
    fill_count: query "publisher-request-count"
    protection_count:  query "publisher-ping-protected-count"
    os_chart: query "publisher-os-protected-count"
    devices_chart: query "publisher-device-protected-count"
    countries_chart: query "publisher-country-protected-count"
    browsers_chart: query "publisher-browser-protected-count"
    ctr_count: {
      success: true
      result: {}
    }
  }).then (analytics)-> 
    for key, value of analytics
      analytics[key] = {
        success: true
        result: value
      }
    
      if analytics.devices_chart.result?
        for device in analytics.devices_chart.result
          if device["user_agent.parsed.device.family"] == "Other"
            device["user_agent.parsed.device.family"] = "Desktop"
      
      
      if analytics.protection_count.result? and analytics.view_count.result?
        analytics.protection_count.result = Math.min 100, Math.floor (analytics.protection_count.result/analytics.view_count.result) * 100
        analytics.protection_count.result = Number analytics.protection_count.result.toFixed(2)
      
      else
        analytics.protection_count = LOAD_ERROR
      
      
      if analytics.fill_count.result? and analytics.impression_count.result?
        analytics.fill_count.result = Math.min 100, Math.floor (analytics.impression_count.result/analytics.fill_count.result) * 100
        analytics.fill_count.result = Number analytics.fill_count.result.toFixed(2)
      
      else
        analytics.fill_count = LOAD_ERROR
      
      
      if analytics.click_count.result? and analytics.impression_count.result?
        analytics.ctr_count.result = {
          query: analytics.protection_count.result.query
          result: Number ((analytics.click_count.result/analytics.impression_count.result) * 100).toFixed(2)
        }
      
      else
        analytics.ctr_count = LOAD_ERROR
    
    return analytics
  
    
  .then (analytics)->
    res.json(analytics)
    
  .catch next
