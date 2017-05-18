EmailTemplate = require('email-templates').EmailTemplate
fs = require "fs"
numeral = require "numeral"
moment = require "moment"
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
    recipient.host = CONFIG.web_server.host
    recipient.numeral = numeral
    recipient.moment = moment
    
    template.render(recipient).then (email)->
      email.to = recipient.to
      return email
    

module.exports.render = render 
module.exports.templates = templates 
module.exports.send = (template_name, recipients)->
  render(template_name, recipients).then (emails)->
    Promise.map emails, (email)->
      LIBS.sendgrid.send email