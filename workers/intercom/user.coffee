module.exports = require("../template") (job)-> 
  
  LIBS.models.User.findAll({
    where: {
      is_demo: false
      #is_admin: false
      id: {
        $ne: LIBS.models.defaults.github_user.id
      }
    }
    include: [{
      model: LIBS.models.Publisher
      as: "publishers"
    }]
  }).each (user)->
    user.intercom(true).then (intercom)->
      LIBS.intercom.updateUser(intercom)