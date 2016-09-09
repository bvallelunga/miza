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

  Promise.props({
    all: req.publisher.reports({
      created_at: {
        $gte: month_ago
      }
    })
    owe: req.publisher.reports({
      paid_at: null
    })
  }).then (props)->            
    res.json {
      billed: LIBS.helpers.past_date "month", null, 1
      cpm: numeral(props.owe.cpm or req.publisher.industry.cpm).format("$0.00a")
      cpc: numeral(props.owe.cpc).format("$0.00[0]a")
      fee: numeral(props.owe.fee or req.publisher.industry.fee).format("0[.]0%")
      owe_short: numeral(props.owe.owed).format("$0[,]000[.]00a")
      owe_long: numeral(props.owe.owed).format("$0[,]000.00")
      revenue: numeral(props.all.revenue).format("$0[,]000a")
      revenue_protected: numeral(props.owe.revenue).format("$0[,]000.00a")
      clicks_revenue: numeral(props.owe.clicks_revenue).format("$0[,]000.00")
      impressions_revenue: numeral(props.owe.impressions_revenue).format("$0[,]000.00")
      impressions: numeral(props.owe.impressions).format("0[,]000")
      clicks: numeral(props.owe.clicks).format("0[,]000")
    }
    
  .catch next
