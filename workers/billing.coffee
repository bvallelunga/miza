# Globals
GLOBAL.CONFIG = require("../config")()
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()

# Check If First Day of the Month
now = new Date()

if CONFIG.is_prod and now.getUTCDate() > 1
  return process.exit()

 
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
      stripe_card: {
        $ne: null 
      }
    }
  }, {
    model: LIBS.models.Industry
    as: "industry"
  }]
}).then (publishers)->
  Promise.all publishers.map (publisher)->
    LIBS.models.Event.count({
      where: {
        publisher_id: publisher.id
        protected: true
        type: "impression"
        paid_at: null
      }
    }).then (impressions)-> 
      amount = impressions/1000 * publisher.industry.cpm * publisher.industry.fee * 1000
      amount_stripe = Math.floor amount * 100
      
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
        where: {
          publisher_id: publisher.id
          protected: true
          type: "impression"
          paid_at: null
        }
      }
        
.then ->
  return process.exit()