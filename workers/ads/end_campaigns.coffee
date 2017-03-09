module.exports = require("../template") {
  intervals: [
    ["ads.end_campaign", "* * * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.Campaign.findAll({
    where: {
      end_at: {
        $ne: null
        $lt: new Date()
      }
      status: {
        $ne: "completed"
      }
    }
  }).each (campaign)->
    console.log campaign.name
    campaign.status = "completed"
    campaign.save()
  
