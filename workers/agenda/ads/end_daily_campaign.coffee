module.exports = require("../template") {
  intervals: [
    ["ads.end_daily_campaign", "10 seconds"]
  ]
  config: {
    priority: "low" 
  }
}, (job)->
  LIBS.models.Campaign.findAll({
    where: {
      quantity_daily_needed: {
        $lte: 0
      }
    }
  }).each (campaign)->
    campaign.quantity_daily_needed = 0
    campaign.active = false
    campaign.save()
  
