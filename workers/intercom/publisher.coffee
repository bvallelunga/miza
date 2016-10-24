module.exports = require("../template") (job)-> 
  
  LIBS.models.Publisher.findAll().each (publisher)->
    publisher.intercom(true).then (intercom)->
      LIBS.intercom.updateCompany(intercom)