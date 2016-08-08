module.exports.up = (sequelize, models)->
  
  Promise.props({
    user: create_user models
    publisher: create_publisher models
  }).then (result)->
    result.user[0].addPublisher result.publisher[0]
    
  
create_user = (models)->
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
  

create_publisher = (models)->
  models.Publisher.findOrCreate({
    where: {
      domain: "miza.io"
    },
    defaults: {
      name: "Demo Publisher"
      is_demo: true
      industry_id: 8
    }
  })

