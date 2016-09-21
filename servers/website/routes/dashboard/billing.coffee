numeral = require "numeral"

module.exports.logs = (req, res, next)->
  LIBS.stripe.charges.list({
    customer: req.publisher.owner.stripe_id
  }).then (list)->  
    res.json list.data.filter((charge)->    
      return Number(charge.metadata.publisher) == req.publisher.id
      
    ).map (charge)->  
      if charge.refunded
        status = "refunded"
      
      else 
        status = charge.status
         
      return {
        id: charge.id.slice(3)
        amount: numeral(charge.amount/100).format("$0[,]000.00a")
        card: {
          brand: charge.source.brand
          last4: charge.source.last4
        }
        status: status
        created: charge.created * 1000
      }
  
  .catch next
  
  
module.exports.metrics = (req, res, next)->
  month_ago = LIBS.helpers.past_date "month", req.query.date
  industry = req.publisher.industry

  req.publisher.reports({
    paid_at: null
    interval: "day"
  }).then (reports)->              
    res.json {
      totals: format_report reports.totals, industry
      all: reports.all.filter (report)->
        return report.owed > 0
      .map format_report
    }
    
  .catch next


format_report = (report)->
  report.cpm = numeral(report.cpm).format("$0.00a")
  report.owed = numeral(report.owed).format("$0[,]000.00")
  report.impressions_owed = numeral(report.impressions_owed).format("$0[,]000.00")
  report.impressions = numeral(report.impressions).format("0[,]000")
  return report
  