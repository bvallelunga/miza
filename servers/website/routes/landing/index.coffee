request = require "request"


module.exports.get_root = (req, res, next)->
  res.render "landing/index", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing", "fa"
  }
  

module.exports.get_loader_io = (req, res, next)->
  res.send CONFIG.loader_io


module.exports.post_beta = (req, res, next)->
  res.render "landing/access_requested", {
    css: req.css.renderTags "modal"
    intercom: {
      email: req.body.email
      access_requested: true
      access_requested_at: new Date()
    }
  }
  
  request.post CONFIG.slack.beta, {
    form: {
      payload: JSON.stringify {
        text: "#{req.body.email} requested access."
      }
    }  
  }
  

module.exports.get_not_found = (req, res, next)->
  res.redirect "/"
  