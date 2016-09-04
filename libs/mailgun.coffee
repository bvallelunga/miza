Mailgun = require 'mailgun-js'

# Exports
module.exports = ->

  mailgun = Mailgun {
    apiKey: CONFIG.mailgun.api_key
    domain: CONFIG.mailgun.domain
  }
  
  
  send = (data)->
    new Promise (res, rej)->
      data.from = CONFIG.mailgun.from
      mailgun.messages().send data, (error, response)->
        if error?
          return rej error
          
        res response
  
  return {
    mailgun: mailgun
    send: send
  }