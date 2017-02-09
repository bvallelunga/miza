numeral = require "numeral"


module.exports.has_payout = (req, res, next)->
  LIBS.models.Payout.findById(req.params.payout).then (payout)->
    if not payout?
      return res.redirect "/admin/payouts"
       
    Promise.resolve().then ->
      if payout.is_transferred
        payout.getTransfers({
          order: [
            ['created_at', 'DESC']
          ]
          include: [
            {
              model: LIBS.models.Publisher
              as: "publisher"
            }
            {
              model: LIBS.models.User
              as: "user"
            }
          ]
        }).then (transfers)->
          payout.transfers = transfers
    
      else
        payout.update_counts()
        
    .then ->
      req.payout = payout
      next()
    
  .catch next


module.exports.get_root = (req, res, next)->
  LIBS.models.Payout.findAll().then (payouts)->
    res.render "admin/payouts/index", {
      js: req.js.renderTags "modal", "admin-payouts", "date-range"
      css: req.css.renderTags "modal", "admin", "fa", "date-range"
      title: "Admin Payouts"
      payouts: payouts
    } 
 
   
module.exports.get_create = (req, res, next)->
  res.render "admin/payouts/payout", {
    js: req.js.renderTags "modal", "admin-payouts"
    css: req.css.renderTags "modal", "admin", "fa", "dashboard"
    title: "Admin Payouts"
    payout: req.payout
    publishers: req.payout.publishers
    transfers: req.payout.transfers
  }
  

module.exports.get_delete = (req, res, next)->
  if req.payout.is_transferred
    return res.redirect "/admin/payouts"
  
  req.payout.destroy().then ->
    res.redirect "/admin/payouts"
    
  .catch next
   
  
module.exports.post_create = (req, res, next)->
  LIBS.models.Payout.create({
    name: req.body.name
    start_at: new Date req.body.start_at
    end_at: new Date req.body.end_at
  }).then (payout)->
    res.json {
      success: true
      next: "/admin/payouts/#{payout.id}"
    }
  
  .catch next

  
module.exports.post_update = (req, res, next)->
  if req.payout.is_transferred
    return next "Payout already transfered!"
  
  Promise.props({
    sources: Promise.filter req.body.sources, (source)->
      return source.name != ""
    .map (source)->
      source.amount = Number(source.amount) or 0
      return source
  }).then (props)->
    req.payout.update({
      fee: Number(req.body.fee) / 100
      sources: props.sources
      note: req.body.note
    })

  .then ->
    res.json {
      success: true
      next: req.path
    }
    
  .catch next
  

module.exports.post_transfer = (req, res, next)->
  if req.payout.is_transferred
    return next "Payout already transfered!"

  req.payout.create_transfers().then ->
    res.json {
      success: true
      next: "/admin/payouts"
    }
    
  .catch next
  