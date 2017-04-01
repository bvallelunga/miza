module.exports = require("../template") {
  intervals: [
    ["ads.start_campain", "* * * * *"]
  ]
  config: {
    priority: "high" 
  }
}, (job)->
  LIBS.models.Campaign.findAll({
    where: {
      start_at: {
        $lte: new Date()
      }
      status: "queued"
    }
  }).each (campaign)->
    campaign.status = "running"
    campaign.save()
  
