module.exports.up = (sequelize, models)->
  Promise.props({
    user: createUser models
    publisher: createPublisher models
  }).then (result)->
    result.user[0].addPublisher result.publisher[0]
    
  
createUser = (models)->
  models.User.findOrCreate({
    where: {
      email: "admin@miza.io"
    },
    defaults: {
      password: "changeme",
      name: "Admin"
      is_admin: true
    }
  })
  

createPublisher = (models)->
  models.Publisher.findOrCreate({
    where: {
      domain: "miza.io"
    },
    defaults: {
      name: "Demo Publisher"
      is_demo: true
    }
  })

