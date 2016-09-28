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
      where: {
        stripe_card: null
      }
    }]
  }).then (publishers)->  
    Promise.map publishers, (publisher)->
      publisher.reports({
        created_at: {
          $gte: LIBS.helpers.past_date "month"
        }
      }).then (report)->        
        return {
          publisher: publisher
          report: report.totals
        }
        
  .filter (data)->
    return data.report.owed > 0
        
  .map (data)->
    return {
      data: {
        publisher: data.publisher
        report: data.report
        user: data.publisher.owner
        billed_on: billed_on
      }
      to: data.publisher.owner.email
    }
    
  .then (emails)->
    LIBS.emails.send "add_payment_info", emails
    
  .then(-> done()).catch (error)->
    if CONFIG.is_prod
      LIBS.bugsnag.notify error
    else
      console.error error
    
    done error