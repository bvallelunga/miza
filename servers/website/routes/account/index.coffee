module.exports.get_root = (req, res, next)->
  js = ["publisher", "modal"]
  css = ["publisher", "fa"]
  dashboard = req.params.dashboard
  dashboards = [
    "profile", "notifications", "billing", "password"
  ]
  
  if dashboard not in dashboards
    return res.redirect "/account/profile"  
    
  if dashboard in ["billing"]
    js = ["publisher", "card"]
    res.locals.config.stripe_key = CONFIG.stripe.public
  
  res.render "account/index", {
    js: req.js.renderTags.apply(req.js, js)
    css: req.css.renderTags.apply(req.css, css)
    title: "Account Settings"
    dashboard: dashboard
  }
  
  
module.exports.profile = require "./profile"
module.exports.notifications = require "./notifications"
module.exports.billing = require "./billing"
module.exports.password = require "./password"