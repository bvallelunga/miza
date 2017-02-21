request = require "request"


module.exports.get_root = (req, res, next)->
  res.render "landing/home", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing", "fa"
  }
  

module.exports.get_about = (req, res, next)->
  res.render "landing/about", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing", "fa"
    title: "About Us"
  } 
  

module.exports.get_monetize = (req, res, next)->
  res.render "landing/monetize", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing", "fa"
    title: "Monetize"
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


module.exports.post_beta = (req, res, next)->
  res.render "landing/access_requested", {
    title: "Access Requested"
    css: req.css.renderTags "modal"
  }
  
  LIBS.intercom.createContact {
    email: req.body.email
  }
  
  LIBS.slack.message {
    text: "#{req.body.name} (#{req.body.email}, #{req.body.phone}) who is the #{req.body.title} of #{req.body.website} requested a demo."
  }
  
  
module.exports.get_dashboard = (req, res, next)->
  if not req.user.is_admin
    return res.redirect "/#{req.user.type}"
    
  res.render "landing/dashboard", {
    title: "Dashboard"
    css: req.css.renderTags "admin", "fa"
  }
  

module.exports.get_not_found = (req, res, next)->
  res.status(404).render "landing/error", {
    error: "404\nPage Not Found"
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
  }
  
  
module.exports.demo = require "./demo"