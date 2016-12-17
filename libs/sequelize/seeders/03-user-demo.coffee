randomstring = require "randomstring"

module.exports.up = (sequelize, models)->
  
  Promise.props({
    user: create_user models
    publishers: create_publishers models
  }).then (result)->  
    Promise.each result.publishers, (publisher)->
      result.user[0].addPublisher publisher[0]
      publisher[0].setOwner result.user[0]
      publisher[0].addNetworks [ 1, 2, 3 ]
    
  
create_user = (models)->
  models.User.findOrCreate({
    where: {
      email: "demo@miza.io"
    },
    defaults: {
      password: randomstring.generate(15)
      name: "Demo User"
      is_demo: true
    }
  })
  

create_publishers = (models)->
  Promise.all [
    models.Publisher.findOrCreate({
      where: {
        domain: "protect.miza.io"
      },
      defaults: {
        name: "Protect Demo"
        is_demo: true
        industry_id: 2
        product: "protect"
      }
    }),
    models.Publisher.findOrCreate({
      where: {
        domain: "network.miza.io"
      },
      defaults: {
        name: "Network Demo"
        is_demo: true
        industry_id: 2
        product: "network"
      }
    }) 
  ]

