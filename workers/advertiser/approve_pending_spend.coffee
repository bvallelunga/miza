module.exports = require("../template") {
  intervals: [
    ["advertiser.approve_pending_spend", "0 0 * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.Advertiser.findAll().each (advertiser)->
    advertiser.approve_spending({
      created_at: {
        $lte: advertiser.auto_approve_at
      }
    })
  
