module.exports = require("../template") {
  intervals: [
    ["ads.start_daily_campain", "0 0 * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.Campaign.findAll({
    where: {
      status: "running"
      active: false
      quantity_daily_needed: 0
      quantity_daily_requested: {
        $ne: null
      }
    }
  }).each (campaign)->
    campaign.quantity_daily_needed = campaign.quantity_daily_requested
    campaign.active = true
    campaign.save()
  
