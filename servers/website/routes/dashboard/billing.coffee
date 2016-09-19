numeral = require "numeral"

module.exports.logs = (req, res, next)->
  req.publisher.getOwner().then (owner)->
    LIBS.stripe.charges.list({
      customer: owner.stripe_id
    })
      
  .then (list)-> 
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
      all: reports.all.map (report)->
        format_report report, industry
    }
    
  .catch next


format_report = (report, industry)->
  report.cpm = numeral(report.cpm or industry.cpm).format("$0.00a")
  report.owed = numeral(report.owed).format("$0[,]000.00")
  report.impressions_owed = numeral(report.impressions_owed).format("$0[,]000.00")
  report.impressions = numeral(report.impressions).format("0[,]000")
  return report
  