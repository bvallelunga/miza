Mixpanel = require "mixpanel"
MixpanelExport = require "mixpanel-data-export"

# Exports
module.exports = ->
  mixpanel = Mixpanel.init CONFIG.mixpanel.key, {
    api_key: CONFIG.mixpanel.key
    api_secret: CONFIG.mixpanel.secret
  }
  mixpanel.export = new MixpanelExport({
    api_key: CONFIG.mixpanel.key
    api_secret: CONFIG.mixpanel.secret
  })
  
  return mixpanel