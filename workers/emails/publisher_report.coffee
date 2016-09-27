moment = require "moment"
numeral = require "numeral"


module.exports = (job, done)->
  query = {}
  data = job.attrs.data or {}
  billed_on = moment(LIBS.helpers.past_date "month", null, 1).format("MMM D")
  
  if data.publisher?
    query.id = data.publisher
  else
    query.is_demo = false
  
  LIBS.models.Publisher.findAll({
    where: query
    include: [{
      model: LIBS.models.User
      as: "owner"
    }, {
      model: LIBS.models.User
      as: "members"
    }]
  }).then (publishers)->
    Promise.map publishers, (publisher)->
      publisher.reports({
        created_at: {
          $gte: LIBS.helpers.past_date "week", null, -1
        }
      }).then (report)->
        report = report.totals
        report.str_clicks = numeral(report.clicks).format("0[,]000")
        report.str_impressions = numeral(report.impressions).format("0[,]000")
        
        return {
          publisher: publisher
          report: report
        }
        
  .filter (data)->
    return data.report.impressions > 0
        
  .each (data)->
    Promise.map data.publisher.members, (user)->
      return {
        data: {
          publisher: data.publisher
          report: data.report
          user: user
          billed_on: billed_on
        }
        to: user.email
      }
    .then (emails)->
      LIBS.emails.send "publisher_report", emails
    
  .then(-> done()).catch (error)->  
    if CONFIG.is_prod
      LIBS.bugsnag.notify error
    else
      console.error error
    
    done error