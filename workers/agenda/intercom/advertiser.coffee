module.exports = require("../template") {
  intervals: [
    ["intercom.advertiser", "4 * * * *"]
  ]
  config: {
    priority: "medium"
  }
}, (job)-> 
  
  LIBS.models.Advertiser.findAll({
    where: {
      is_demo: false
    }
  }).each (advertiser)->
    advertiser.intercom(true).then (intercom)->
      LIBS.intercom.updateCompany(intercom)