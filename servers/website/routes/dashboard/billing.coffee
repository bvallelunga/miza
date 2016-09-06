numeral = require "numeral"

module.exports.logs = (req, res, next)->
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
  
  
module.exports.metrics = (req, res, next)->
  month_ago = LIBS.helpers.past_date "month", req.query.date

  Promise.props({
#     owed_impressions: LIBS.models.Event.count({
#       where: {
#         publisher_id: req.publisher.id
#         protected: true
#         type: "impression"
#         paid_at: null
#       }
#     })
    impressions: LIBS.mixpanel.export.segmentation({
      event: "ADS.EVENT.Impression"
      from_date: LIBS.helpers.date_string month_ago
      to_date: LIBS.helpers.date_string new Date()
      unit: "month"
      method: "numeric"
      where: 'properties["Protected"] == true and properties["Publisher ID"] == ' + req.publisher.id
    }).then(LIBS.mixpanel.export.sum_segments)
  }).then (props)-> 
    industry = req.publisher.industry
    next_month = LIBS.helpers.past_date "month+1"
   
    res.json {
      billed: next_month
      cpm: numeral(industry.cpm).format("$0.00a")
      owe: numeral(LIBS.models.Publisher.owed(props.impressions, industry)).format("$0[,]000[.]00a")
      fee: numeral(industry.fee).format("0[.]0%")
      revenue: numeral(LIBS.models.Publisher.revenue(props.impressions, industry)).format("$0[,]000.00a")
    }
    
  .catch next
