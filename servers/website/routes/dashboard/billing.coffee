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

  req.publisher.reports({
      paid_at: null
  }).then (props)->            
    res.json {
      cpm: numeral(props.cpm or req.publisher.industry.cpm).format("$0.00a")
      owed: numeral(props.owed).format("$0[,]000.00")
      impressions_owed: numeral(props.impressions_owed).format("$0[,]000.00")
      impressions: numeral(props.impressions).format("0[,]000")
      clicks: numeral(props.clicks).format("0[,]000")
      clicks_owed: numeral(props.clicks_owed).format("$0[,]000.00")
      cpc: numeral(props.cpc).format("$0.00a")
    }
    
  .catch next
