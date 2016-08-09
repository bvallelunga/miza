module.exports.up = (sequelize, models)->
  
  Promise.all CONFIG.default_user_access.map (access)->
    return create_user_access models, access
 
 
create_user_access = (models, access)->
  models.UserAccess.findOrCreate({
    where: {
      email: access.email
    }
    defaults: {
      is_admin: access.is_admin
    }
  })
