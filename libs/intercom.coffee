Intercom = require "intercom.io"

# Exports
module.exports = ->
  return new Intercom(CONFIG.intercom.app_id, CONFIG.intercom.api_key)