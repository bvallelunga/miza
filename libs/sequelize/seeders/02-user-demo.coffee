randomstring = require "randomstring"

module.exports.up = (sequelize, models)->
  
  Promise.props({
    user: create_user models
    publishers: create_publishers models
  }).then (result)->  
    Promise.each result.publishers, (publisher)->
      result.user[0].addPublisher publisher[0]
      publisher[0].setOwner result.user[0]
    
  
create_user = (models)->
  models.User.findOrCreate({
    where: {
      email: "demo@miza.io"
    },
    defaults: {
      password: randomstring.generate(15)
      name: "Demo User"
      is_demo: true
      type: "all"
    }
  })
  

create_publishers = (models)->
  Promise.all [
    models.Publisher.findOrCreate({
      where: {
        domain: "network.miza.io"
      },
      defaults: {
        name: "Network Demo"
        is_demo: true
        product: "network"
        industry_id: 1
        fee: 0.75
      }
    }) 
  ]

