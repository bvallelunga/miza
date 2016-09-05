Mixpanel = require "mixpanel"
MixpanelExport = require "mixpanel-data-export"

# Exports
module.exports = ->
  mixpanel = Mixpanel.init CONFIG.mixpanel.key
  mixpanel.export = new MixpanelExport({
    api_key: CONFIG.mixpanel.key
    api_secret: CONFIG.mixpanel.secret
  })
  mixpanel.export.sum_segments = (results)->
    if not results.data?
      return 0
    
    events = 0
    
    for key, days of results.data.values
      events += Object.keys(days).map (day)->
        return days[day]
        
      .reduce ((total, item) -> total + item), 0
    
    return events
  
  return mixpanel