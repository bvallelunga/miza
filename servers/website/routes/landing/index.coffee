request = require "request"
moment = require "moment"  

module.exports.get_root = (req, res, next)->
  return res.redirect "/supply"

  res.render "landing/home", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
  }


module.exports.get_about = (req, res, next)->
  res.render "landing/about", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "About Us"
  } 


module.exports.get_loader_io = (req, res, next)->
  res.send CONFIG.loader_io
  

module.exports.get_legal = (req, res, next)->
  document_url = CONFIG.legal[req.params.document]

  if not document_url?
    return res.redirect "/"

  res.render "landing/legal", {
    js: req.js.renderTags "landing"
    css: req.css.renderTags "landing"
    document_url: document_url
    title: "Legal"
  }
  

module.exports.get_deck = (req, res, next)->
  document_url = CONFIG.decks[req.params.deck]

  if not document_url?
    return res.redirect "/"

  res.render "landing/decks", {
    js: req.js.renderTags "landing"
    css: req.css.renderTags "landing"
    document_url: document_url
    title: "Decks"
    user_simulate: true
  }
  

module.exports.get_optout = (req, res, next)->
  res.render "landing/optout", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    ip_address: req.ip or req.ips
    title: "OptOut"
  }


module.exports.post_optout = (req, res, next)->
  LIBS.models.OptOut.create({
    email: req.body.email.toLowerCase().trim()
    ip_address: req.ip or req.ips
  }).then ->
    res.json {
      success: true
      message: "We have disabled Miza protected ads for your IP address"
      next: "/"
    }
  
  
module.exports.get_dashboard = (req, res, next)->
  if not (req.user.is_admin or req.user.type == "all")
    return res.redirect "/dashboard/#{req.user.type}"
    
  res.render "landing/dashboard", {
    title: "Dashboard"
    js: req.js.renderTags "fa"
    css: req.css.renderTags "admin"
    dashboard: "dashboard"
  }
  

module.exports.get_not_found = (req, res, next)->
  res.status(404).render "landing/error", {
    error: "404\nPage Not Found"
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
  }
  

module.exports.get_shortener = (req, res, next)->
  LIBS.models.Shortener.findOne({
    where: {
      key: req.params.key
      created_at: {
        $gte: moment().subtract(1, "month").toDate()
      }
    }
  }).then (shortner)->
    if not shortner?
      return req._routes.landing.get_not_found(req, res)
      
    res.redirect shortner.url
  
  .catch next
  
  
module.exports.supply = require "./supply"
module.exports.demand = require "./demand"