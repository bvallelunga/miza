# Globals
GLOBAL.CONFIG = require("../config")()
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()

# Check If First Day of the Month
now = new Date()
# 
# if now.getUTCDate() > 1
#   return process.exit()
  
 
# Fetch All Customers
LIBS.models.User.findAll({
  where: {
    stripe_card: {
      $ne: null 
    }
  }
  include: [{
    model: LIBS.models.Publisher
    as: "publishers"
  }]
}).then (users)->
  Promise.all users.map (user)->
    Promise.all user.publishers.map (publisher)->
      Promise.props({
        impressions: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            protected: true
            type: "impression"
            paid_at: null
          }
        })
        industry: publisher.getIndustry()
      }).then (props)-> 
        amount = Math.floor(props.impressions/1000 * props.industry.cpm * props.industry.fee * 100)
        
        if amount <= 49
          return Promise.resolve(false)
        
        LIBS.stripe.charges.create({
          amount: amount
          customer: user.stripe_id
          currency: "usd"
        })
      
      .then (charged)->
        if charged == false
          return Promise.resolve()
      
        LIBS.models.Event.update({
          paid_at: now
        }, {
          where: {
            publisher_id: publisher.id
            protected: true
            type: "impression"
            paid_at: null
          }
        })
        
.then ->
  return process.exit()