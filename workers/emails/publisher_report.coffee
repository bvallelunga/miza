moment = require "moment"
numeral = require "numeral"


module.exports = require("../template") (job)-> 
  query = {}
  data = job.attrs.data or {}
  billed_on = moment(LIBS.helpers.past_date "month", null, 1).format("MMM D")
  
  if data.publisher?
    query.id = data.publisher
  else if CONFIG.is_prod
    query.is_demo = false
  
  LIBS.models.Publisher.findAll({
    where: query
    include: [{
      model: LIBS.models.User
      as: "owner"
    }, {
      model: LIBS.models.User
      as: "members"
      where: {
        notifications: {
          weekly_reports: {
            $ne: false
          }
        }
      }
    }]
  }).then (publishers)->  
    Promise.map publishers, (publisher)->
      publisher.reports({
        created_at: {
          $gte: LIBS.helpers.past_date "week"
        }
      }).then (report)->        
        return {
          publisher: publisher
          report: report.totals
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
