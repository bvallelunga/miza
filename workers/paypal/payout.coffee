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
    }
    include: [{
      model: LIBS.models.User
      as: "user"
      where: {
        paypal: {
          $not: null
        }
      }
    }]
  }).then (transfers)->  
    if transfers.length == 0
      return Promise.resolve()
  
    new Promise (res, rej)->
      LIBS.paypal.payout.create {
        sender_batch_header: {
          sender_batch_id: transfers[0].payout_id
          email_subject: "Miza Inc. Payout"
        }
        items: transfers.map (transfer)->
          return {
            recipient_type: "EMAIL"
            receiver: transfer.user.paypal
            note: transfer.note
            sender_item_id: transfer.id
            amount: {
              value: transfer.amount
              currency: "USD"
            }
          }
      }, (error, payout)->
        if error?
          return rej error
          
        console.log payout
          
        res transfers
  
    .map (transfer)->
      transfer.paypal = transfer.user.paypal
      transfer.is_transferred = true
      transfer.transferred_at = new Date()
      transfer.save()
  