module.exports = require("../template") {
  intervals: [
    ["intercom.publisher", "2 * * * *"]
  ]
  config: {
    priority: "medium"
  }
}, (job)-> 
  
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
    include: [{
      model: LIBS.models.User
      as: "owner"
    }, {
      model: LIBS.models.User
      as: "admin_contact"
    }, {
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).each (publisher)->
    publisher.intercom(true).then (intercom)->
      LIBS.intercom.updateCompany(intercom)