module.exports.up = (sequelize, models)->
  
  Promise.all CONFIG.default_user_access.map (email)->
    return create_user_access models, email
 
 
create_user_access = (models, email)->
  models.UserAccess.findOrCreate({
    where: {
      email: email
    }
  })
