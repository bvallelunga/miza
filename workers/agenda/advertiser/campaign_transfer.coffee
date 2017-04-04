module.exports = require("../template") {
  intervals: [
    ["advertiser.campaign_transfer", "5 * * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.Campaign.findAll({
    paranoid: false
    where: {
      status: "completed"
      transferred_at: null
    }
  }).each (campaign)->
    campaign.create_transfer()
