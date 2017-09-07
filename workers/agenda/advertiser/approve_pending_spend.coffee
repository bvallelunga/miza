module.exports = require("../template") {
  intervals: [
    ["advertiser.approve_pending_spend", "0 0 * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.Advertiser.findAll({
    include: [{
      model: LIBS.models.User
      as: "owner"
      where: {
        stripe_card: {
          $ne: null
        }
      }
    }]
  }).each (advertiser)->
    console.log advertiser.name
  
    advertiser.approve_spending({
      created_at: {
        $lte: advertiser.auto_approve_at
      }
    }).catch -> Promise.resolve()
  
