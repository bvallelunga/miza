numeral = require "numeral"

module.exports.get_logs = (req, res, next)->
  LIBS.stripe.charges.list({
    customer: req.user.stripe_id
  }).then (list)->  
    res.json list.data.map (charge)->
      status = "pending"
        
      if charge.refunded
        status = "refunded"
      
      else if charge.paid
        status = "paid"
         
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
  month_ago = new Date()
  month_ago.setMonth month_ago.getMonth() - 1
  
  Promise.props({
    impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "impression"
        created_at: {
          $gte: month_ago
        }
      }
    })
    industry: req.publisher.getIndustry()
  }).then (props)->    
    res.json {
      impressions: numeral(props.impressions).format("0a")
      cpm: numeral(props.industry.cpm).format("$0.00a")
      owe: numeral(props.impressions/1000 * props.industry.cpm * props.industry.fee).format("$0[,]000.00a")
      fee: numeral(props.industry.fee).format("0[.]0%")
      revenue: numeral(props.impressions/1000 * props.industry.cpm).format("$0[,]000.00a")
    }
    
  .catch next
