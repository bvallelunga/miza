SendGrid = require 'sendgrid'

# Exports
module.exports = ->

  sendgrid = SendGrid(CONFIG.sendgrid.api_key)
  helper = sendgrid.mail
  from_email = new helper.Email(CONFIG.sendgrid.from)
  
  send = (data)->  
    to_email = new helper.Email(data.to)
    content = new helper.Content("text/plain", data.text)
    mail = new helper.Mail(from_email, data.subject, to_email, content)
    
    return sendgrid.API sendgrid.emptyRequest({
      method: 'POST',
      path: '/v3/mail/send',
      body: mail.toJSON()
    })
  
  return {
    sendgrid: sendgrid
    send: send
  }