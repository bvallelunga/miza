numeral = require "numeral"

module.exports.get_logs = (req, res, next)->
  LIBS.stripe.charges.list({
    customer: req.user.stripe_id
  }).then (list)-> 
  
    res.json list.data.map (charge)->  
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
  
  
module.exports.get_metrics = (req, res, next)->
  LIBS.models.Event.count({
    where: {
      publisher_id: req.publisher.id
      protected: true
      type: "impression"
      paid_at: null
    }
  }).then (impressions)-> 
    industry = req.publisher.industry
    next_month = new Date()
    next_month.setUTCMonth next_month.getUTCMonth() + 1
    next_month.setUTCDate 1
   
    res.json {
      billed: next_month
      cpm: numeral(industry.cpm).format("$0.00a")
      owe: numeral(impressions/1000 * industry.cpm * industry.fee).format("$0[,]000[.]00a")
      fee: numeral(industry.fee).format("0[.]0%")
      revenue: numeral(impressions/1000 * industry.cpm).format("$0[,]000.00a")
    }
    
  .catch next
