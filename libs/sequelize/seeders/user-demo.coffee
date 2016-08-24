randomstring = require "randomstring"

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
      password: randomstring.generate(15)
      name: "Demo User"
    }
  })
  

create_publisher = (models)->
  models.Publisher.findOrCreate({
    where: {
      domain: "miza.io"
    },
    defaults: {
      name: "Demo"
      is_demo: true
      industry_id: 11
    }
  })

