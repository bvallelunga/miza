moment = require "moment"


module.exports = (job, done)->
  date = moment()
  invoice_description = "Invoice for #{date.format("MMMM YYYY")}"
  
  if CONFIG.is_prod and date.date() != 1
    return done "Not the first of the month!"
   
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
      }).then (reports)->
        amount_owed = Math.floor reports.totals.owed * 100

        if amount_owed <= 49
          return Promise.resolve false
        
        LIBS.mixpanel.people.track_charge publisher.owner.id, amount_owed
        
        LIBS.stripe.charges.create {
          amount: amount_owed
          customer: publisher.owner.stripe_id
          currency: "usd"
          description: invoice_description
          receipt_email: publisher.owner.email
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

  .then(-> done()).catch(done)