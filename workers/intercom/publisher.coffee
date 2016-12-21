module.exports = require("../template") {
  intervals: [
    ["intercom.publisher", "0 * * * *"]
  ]
  config: {
    priority: "medium"
  }
}, (job)-> 
  
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
  }).each (publisher)->
    publisher.intercom(true).then (intercom)->
      LIBS.intercom.updateCompany(intercom)