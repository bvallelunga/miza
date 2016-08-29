request = require "request"

module.exports.message = (message)->
  if not CONFIG.disable.slack
    request.post CONFIG.slack.beta, {
      form: {
        payload: JSON.stringify message  
      }
    }