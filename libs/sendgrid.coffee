SendGrid = require 'sendgrid'

# Exports
module.exports = ->
  sendgrid = SendGrid(CONFIG.sendgrid.api_key)
  helper = SendGrid.mail  
  from_email = new helper.Email(CONFIG.sendgrid.from)
  
  send = (data)->  
    mail = new helper.Mail()
    mail.setFrom from_email
    mail.setSubject data.subject
    
    personalization = new helper.Personalization()
    personalization.addTo new helper.Email data.to
    mail.addPersonalization personalization
    
    if data.text?
      mail.addContent new helper.Content("text/plain", data.text)
      
    if data.html?
      mail.addContent new helper.Content("text/html", data.html)
    
    return sendgrid.API sendgrid.emptyRequest({
      method: 'POST',
      path: '/v3/mail/send',
      body: mail.toJSON()
    })
  
  return {
    sendgrid: sendgrid
    send: send
  }