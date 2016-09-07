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
      billed: LIBS.helpers.past_date "month+1"
      cpm: numeral(props.owe.cpm).format("$0.00a")
      fee: numeral(props.owe.fee).format("0[.]0%")
      owe: numeral(props.owe.owed).format("$0[,]000[.]00a")
      revenue: numeral(props.all.revenue).format("$0[,]000[.]00a")
    }
    
  .catch next
