moment = require "moment"


module.exports = require("../template") {
  intervals: [
    ["paypal.payout.daily", '0 1 * * *']
  ]
  config: {
    concurrency: 1
    priority: "highest"
  }
}, (job)-> 
  LIBS.models.Transfer.findAll({
    where: {
      is_transferred: false
      type: "payout"
    }
    include: [{
      model: LIBS.models.User
      as: "user"
      where: {
        paypal: {
          $ne: null
        }
      }
    }]
  }).each (transfer)->    
    new Promise (res, rej)->
      LIBS.paypal.payout.create {
        sender_batch_header: {
          sender_batch_id: transfer.payout_id
          email_subject: "Miza Inc. Payout"
        }
        items: [{
          recipient_type: "EMAIL"
          receiver: transfer.user.paypal
          note: transfer.note
          sender_item_id: transfer.id
          amount: {
            value: transfer.amount
            currency: "USD"
          }
        }]
      }, (error, payout)->
        if error?
          return rej error
          
        transfer.config.paypal = payout
          
        res transfer.update({
          paypal: transfer.user.paypal
          is_transferred: true
          transferred_at: new Date()
          config: transfer.config
        })

  