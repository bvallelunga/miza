module.exports = require("../template") {
  intervals: [
    ["ads.end_campaign", "10 seconds"]
  ]
  config: {
    priority: "low" 
  }
}, (job)->
  LIBS.models.Campaign.findAll({
    where: {
      $or: [{
        end_at: {
          $lte: new Date()
        }
      }, {
        quantity_needed: {
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
  
