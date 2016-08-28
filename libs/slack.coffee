request = require "request"

module.exports.message = (message)->
  request.post CONFIG.slack.beta, {
    form: {
      payload: JSON.stringify message  
    }
  }