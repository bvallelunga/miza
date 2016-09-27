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
    

publisher_report = (data)->
  data.billed_on = moment(LIBS.helpers.past_date "month", null, 1).format("MMM D")
  data.report = data.publisher.reports({
    created_at: {
      $gte: LIBS.helpers.past_date "week", null, -1
    }
  }).then (report)->
    report = report.totals
    report.str_clicks = numeral(report.clicks).format("0[,]000")
    report.str_impressions = numeral(report.impressions).format("0[,]000")
    return report 

  Promise.props data
  
  
forgot_password = (data)->
  data.random = randomstring.generate({
    length: 5
    charset: 'alphabetic'
  })
  
  return data


module.exports.get = (req, res, next)->
  template = req.params.template

  load_demo().then (data)->  
    if template == "publisher_report"    
      return publisher_report data
      
    if template == "forgot_password"
      return forgot_password data
    
    return data
    
  .then (data)->    
    LIBS.emails.render(template, [{
      data: data
      to: data.user.email
    }])
  
  .then (emails)->
    html = emails[0].html
    text = emails[0].text or ""
    text = text.replace(/\n\n/g, '<br/><br/>')
    res.send html or text
    
  .catch next
