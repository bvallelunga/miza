module.exports = (sequelize, models)->
  
  Promise.props({
    user: createUser models
    publisher: createPublisher models
  }).then (result)->
    result.user[0].addPublisher result.publisher[0]
    
  
createUser = (models)->
  models.User.findOrCreate({
    where: {
      email: "admin@sledge.io"
    },
    defaults: {
      password: "1burrito2go",
      name: "Admin"
      is_admin: true
    }
  })
  

createPublisher = (models)->
  models.Publisher.findOrCreate({
    where: {
      domain: "sledge.io"
    },
    defaults: {
      name: "Demo Publisher"
    }
  })

