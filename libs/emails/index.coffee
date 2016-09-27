EmailTemplate = require('email-templates').EmailTemplate
fs = require "fs"
templates = {}

for directory in fs.readdirSync __dirname
  path = "#{__dirname}/#{directory}"
  
  if fs.statSync(path).isDirectory()
    templates[directory] = new EmailTemplate path
    

render = (template_name, recipients)->
  template = templates[template_name]

  if not template?
    return Promise.reject "Template not found"
    
  Promise.all recipients.map (recipient)->
    recipient.company = CONFIG.general.company
    recipient.host = CONFIG.web_server.domain
    template.render(recipient).then (email)->
      email.to = recipient.to
      return email
    

module.exports.render = render 
module.exports.send = (template_name, recipients)->
  render(template_name, recipients).then (emails)->
    Promise.map emails, (email)->
      LIBS.sendgrid.send email