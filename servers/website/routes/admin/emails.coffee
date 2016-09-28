moment = require "moment"
numeral = require "numeral"
randomstring = require "randomstring"


load_demo = ->
  LIBS.models.User.findOne({
    where: {
      email: "demo@miza.io"
    }
    include: [{
      model: LIBS.models.Publisher
      as: "publishers"
      include: [{
        model: LIBS.models.User
        as: "owner"
      }]
    }]
  }).then (user)->
    return {
      user: user
      publisher: user.publishers[0]
    }
    

publisher_report = (data, range)->
  data.billed_on = moment(LIBS.helpers.past_date "month", null, 1).format("MMM D")
  data.report = data.publisher.reports({
    created_at: {
      $gte: LIBS.helpers.past_date range
    }
  }).then (report)->
    return report.totals

  Promise.props data
  

forgot_password = (data)->
  data.random = randomstring.generate({
    length: 5
    charset: 'alphabetic'
  })
  
  return data


module.exports.get = (req, res, next)->
  res.render "admin/emails", {
    js: req.js.renderTags "modal", "admin-emails"
    css: req.css.renderTags "modal", "admin"
    title: "Admin Emails"
    templates: Object.keys LIBS.emails.templates
  } 


module.exports.email = (req, res, next)->
  template = req.params.template

  load_demo().then (data)->  
    if template == "publisher_report"    
      return publisher_report data, "week"
      
    if template == "forgot_password"
      return forgot_password data
      
    if template == "add_payment_info"
      return publisher_report data, "month"
    
    return data
    
  .then (data)->    
    LIBS.emails.render(template, [{
      data: data
      to: data.user.email
    }])
  
  .then (emails)->
    html = emails[0].html
    text = emails[0].text or ""
    text = text.replace /\n\n/g, '<br/><br/>'
    
    res.json {
      subject: emails[0].subject
      body: html or text
    }
    
  .catch next
