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
      $or: [{
        end_at: {
          $lte: new Date()
        }
      }, {
        impressions_needed: {
          $lte: 0
        }
      }]
      status: {
        $ne: "completed"
      }
    }
  }).each (campaign)->
    campaign.status = "completed"
    campaign.save()
  
