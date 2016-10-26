module.exports = require("../template") (job)-> 
  
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
  }).each (publisher)->
    publisher.intercom(true).then (intercom)->
      console.log intercom
      LIBS.intercom.updateCompany(intercom)