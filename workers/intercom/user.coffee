module.exports = require("../template") { 
  intervals: [
    ["intercom.user", "0 * * * *"]
  ]
  config: {
    priority: "medium"
  }
}, (job)-> 

  LIBS.models.User.findAll({
    where: {
      is_demo: false
      is_admin: false
    }
    include: [{
      model: LIBS.models.Publisher
      as: "publishers"
    }]
  }).each (user)->
    user.intercom(true).then (intercom)->
      LIBS.intercom.updateUser(intercom)