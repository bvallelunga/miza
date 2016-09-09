# Config
GLOBAL.CONFIG = require("../../config")()


# Check If First Day of the Month
now = new Date()

if CONFIG.is_prod and now.getUTCDate() > 1
  return process.exit()
  
  
# Imports
moment = require "moment"

 
# Startup & Configure
require("../../startup") false, ->
  invoice_description = "Invoice for #{moment().format("MMMM YYYY")}"
   
  LIBS.models.Publisher.findAll({
    include: [{
      model: LIBS.models.User
      as: "owner"
      where: {
        stripe_card: {
          $not: null
        }
      }
    }]
  }).then (publishers)->  
    Promise.all publishers.map (publisher)->
      publisher.reports({
        paid_at: null
      }).then (report)->
        amount_owed = Math.floor report.owed * 100 * 1000

        if amount_owed <= 49
          return Promise.resolve false
        
        LIBS.mixpanel.people.track_charge publisher.owner.id, amount_owed
        
        LIBS.stripe.charges.create {
          amount: amount_owed
          customer: publisher.owner.stripe_id
          currency: "usd"
          description: invoice_description
          metadata: {
            user: publisher.owner.id
            publisher: publisher.id
          }
        }
      
      .then (charged)->          
        if charged == false
          return Promise.resolve()
      
        LIBS.models.PublisherReport.update {
          paid_at: new Date()
        }, {
          where: {
            paid_at: null
          }
        }
        
  .then ->
    process.exit()

  .catch console.error