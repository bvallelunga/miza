DATA_ERROR = {
  success: false
  error: "No Data Available"
}

module.exports.get = (req, res, next)->  
  query = (query_name)->
    LIBS.keen.fetchDataset(query_name, {
      index_by: req.publisher.key
      timeframe: "this_month"
    }).catch (error)->
      LIBS.bugsnag.notify error
      console.log error
      return DATA_ERROR
  
  Promise.props({
    impressions_chart: Promise.all([
      query "publisher-impression-chart"
      query "publisher-click-chart"
    ])
    impression_count: flattener query "publisher-impression-count"
    click_count: flattener query "publisher-click-count"
    view_count: flattener query "publisher-ping-count"
    fill_count: flattener query "publisher-request-count"
    protection_count: flattener query "publisher-ping-protected-count"
    os_chart: flattener query "publisher-os-protected-count"
    devices_chart: flattener query "publisher-device-protected-count"
    countries_chart: flattener query "publisher-country-protected-count"
    browsers_chart: flattener query "publisher-browser-protected-count"
    ctr_count: DATA_ERROR
  }).then (analytics)->     
    if analytics.devices_chart.result?
      for device in analytics.devices_chart.result
        if device["user_agent.parsed.device.family"] == "Other"
          device["user_agent.parsed.device.family"] = "Desktop"
      
    if analytics.protection_count.result? and analytics.view_count.result?
      analytics.protection_count.result = Math.min 100, Math.floor (analytics.protection_count.result/analytics.view_count.result) * 100
      analytics.protection_count.result = Number analytics.protection_count.result.toFixed(2)
    
    else
      analytics.protection_count = DATA_ERROR
    
    
    if analytics.fill_count.result? and analytics.impression_count.result?
      analytics.fill_count.result = Math.min 100, Math.floor (analytics.impression_count.result/analytics.fill_count.result) * 100
      analytics.fill_count.result = Number analytics.fill_count.result.toFixed(2)
    
    else
      analytics.fill_count = DATA_ERROR
    
    
    if analytics.click_count.result? and analytics.impression_count.result?
      analytics.ctr_count = {
        metadata: analytics.protection_count.metadata
        result: Number ((analytics.click_count.result/analytics.impression_count.result) * 100).toFixed(2)
      }
    
    for key, value of analytics
      if typeof value.result == "object" and value.result.length == 0
        analytics[key] = DATA_ERROR
        continue

      analytics[key] = {
        success: true
        result: value
      }
    
    return analytics
  
    
  .then (analytics)->
    res.json(analytics)
    
  .catch next
  

flattener = (promise)->
  promise.then (data)->
    return {
      metadata: data.metadata
      result: data.result[0].value
    }
