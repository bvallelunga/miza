moment = require "moment"

module.exports.get = (req, res, next)->  
  query = (query_name, timeframe, interval)->
    LIBS.keen.fetchDataset(query_name, {
      index_by: req.publisher.key
      timeframe: timeframe or "this_1_months"
    }, interval).catch (error)->
      LIBS.bugsnag.notify error
      console.log error
      return LIBS.keen.errors.DATA
  
  month_timeframe = JSON.stringify({
    start: moment.utc().startOf("month").toDate()
    end: moment.utc().add(2, "day").startOf("day").toISOString()
  })
  
  Promise.props({
    impressions_chart: Promise.all([
      query "publisher-impression-chart", month_timeframe, "daily"
      query "publisher-click-chart", month_timeframe, "daily"
    ])
    impression_count: flattener query "publisher-impression-count"
    click_count: flattener query "publisher-click-count"
    view_count: flattener query "publisher-ping-count"
    request_count: flattener query "publisher-request-count"
    delivery_count: flattener query "publisher-delivery-count"
    protection_count: flattener query "publisher-ping-protected-count"
    os_chart: limiter query "publisher-os-protected-count"
    devices_chart: limiter query "publisher-device-protected-count"
    countries_chart: limiter query "publisher-country-protected-count"
    browsers_chart: limiter query "publisher-browser-protected-count"
    ctr_count: LIBS.keen.errors.DATA
    fill_count: LIBS.keen.errors.DATA
  }).then (analytics)->         
    if analytics.devices_chart.result?
      for device in analytics.devices_chart.result
        if device["user_agent.parsed.device.family"] == "Other"
          device["user_agent.parsed.device.family"] = "Desktop"
      
    if analytics.protection_count.result? and analytics.view_count.result?
      analytics.protection_count.result = Math.min 100, Math.floor (analytics.protection_count.result/Math.max(1, analytics.view_count.result)) * 100
      analytics.protection_count.result = Number(analytics.protection_count.result.toFixed(2))
    
    else
      analytics.protection_count = LIBS.keen.errors.DATA
    
    
    if analytics.request_count.result? and analytics.delivery_count.result?
      result = Math.min 100, Math.floor (analytics.delivery_count.result/Math.max(1, analytics.request_count.result)) * 100
      analytics.fill_count = {
        metadata: analytics.delivery_count.metadata
        result: Number result.toFixed(2)
      }

    
    if analytics.click_count.result? and analytics.impression_count.result?
      analytics.ctr_count = {
        metadata: analytics.protection_count.metadata
        result: Number ((analytics.click_count.result/Math.max(1, analytics.impression_count.result)) * 100).toFixed(2)
      }
    
    for key, value of analytics
      if typeof value.result == "object" and value.result.length == 0
        analytics[key] = LIBS.keen.errors.DATA
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
    if not data.result? or data.result.length == 0
      return data
      
    result = 0
    
    for temp in data.result
      result += temp.value
  
    return {
      metadata: data.metadata
      result: result
    }


limiter = (promise)->
  promise.then (data)->        
    if not data.result? or data.result.length == 0
      return data
    
    data.result = data.result.sort (a, b)->
      return b.result - a.result
      
    .slice(0, 15)
  
    return data
