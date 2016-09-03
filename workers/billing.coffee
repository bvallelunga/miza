# New Relic
require("newrelic")


# Globals
GLOBAL.CONFIG = require("../config")()
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()


# Check If First Day of the Month
now = new Date()

if CONFIG.is_prod and now.getUTCDate() > 1
  return process.exit()
 
 
# Enable Concurrency
require("throng") CONFIG.concurrency, ->
   
  # Fetch All Customers
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
    include: [{
      model: LIBS.models.User
      as: "owner"
      where: {
        is_demo: false
        is_admin: false
      }
    }, {
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).then (publishers)->
    Promise.all publishers.map (publisher)->
      event_query = {
        publisher_id: publisher.id
        protected: true
        type: "impression"
        paid_at: null
      }
    
      LIBS.models.Event.count({
        where: event_query
      }).then (impressions)-> 
        amount = LIBS.models.Publisher.owed(impressions, publisher.industry)
        amount_stripe = Math.floor amount * 100
        
        if not publisher.owner.stripe_card? and publisher.industry.fee == 0
          return Promise.resolve true
        
        if amount_stripe <= 49
          return Promise.resolve false
        
        LIBS.mixpanel.people.track_charge publisher.owner.id, amount
        
        LIBS.stripe.charges.create {
          amount: amount_stripe
          customer: publisher.owner.stripe_id
          currency: "usd"
        }
      
      .then (charged)->    
        if charged == false
          return Promise.resolve()
      
        LIBS.models.Event.update {
          paid_at: now
        }, {
          where: event_query
        }
          
  .then ->
    return process.exit()