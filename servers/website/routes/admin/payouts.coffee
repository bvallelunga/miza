numeral = require "numeral"

module.exports.has_payout = (req, res, next)->
  LIBS.models.Payout.findById(req.params.payout).then (payout)->
    if not payout?
      return res.redirect "/admin/payouts"
    
    req.payout = payout
    
    if payout.is_transferred
      return payout.fetch_transfers()
      
    return payout.generate_transfers()  
  
  .then(-> next()).catch next


module.exports.get_root = (req, res, next)->
  LIBS.models.Payout.findAll({
    order: [
      ["created_at", "DESC"]
    ]
  }).then (payouts)->
    res.render "admin/payouts/index", {
      js: req.js.renderTags "modal", "admin-payouts", "date-range", "fa"
      css: req.css.renderTags "modal", "admin", "date-range"
      title: "Admin Payouts"
      payouts: payouts
      dashboard: "admin"
    } 
 
   
module.exports.get_create = (req, res, next)->
  res.render "admin/payouts/payout", {
    js: req.js.renderTags "modal", "admin-payouts", "fa"
    css: req.css.renderTags "admin", "dashboard"
    title: "Admin Payouts"
    payout: req.payout
    dashboard: "admin"
    config: {
      payout: req.payout.id
    }
  }
  

module.exports.post_delete = (req, res, next)->
  if req.payout.is_transferred
    return next "Payout already transfered!"
  
  req.payout.destroy().then ->
    res.json({
      success: true
      next: "/admin/payouts"
    })
    
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
  
  req.payout.update({
    fee: Number(req.body.fee) / 100
    note: req.body.note
    name: req.body.name
  }).then ->
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
  