module.exports = require("../template") {
  intervals: [
    ["ads.end_campaign_industry", "* * * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.CampaignIndustry.findAll({
    where: {
      quantity_needed: {
        $lte: 0
      }
      status: {
        $ne: "completed"
      }
    }
  }).each (campaignIndustry)->
    campaignIndustry.status = "completed"
    campaignIndustry.save()
  
