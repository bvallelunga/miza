module.exports.up = (sequelize, models)->
  
  Promise.props({
    user: create_user models
    publisher: create_publisher models
  }).then (result)->
    result.user[0].addPublisher result.publisher[0]
    
  
create_user = (models)->
  models.User.findOrCreate({
    where: {
      email: "demo@miza.io"
    },
    defaults: {
      password: "demo",
      name: "Demo User"
    }
  })
  

create_publisher = (models)->
  models.Publisher.findOrCreate({
    where: {
      domain: "demo.miza.io"
    },
    defaults: {
      name: "Demo Publisher"
      is_demo: true
      industry_id: 11
    }
  })

