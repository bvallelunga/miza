module.exports.get_root = (req, res, next)->
  js = ["dashboard", "modal", "fa"]
  css = ["dashboard", "account"]
  dashboard = req.params.dashboard
  dashboards = [
    "profile", "notifications", "billing", "password"
  ]
  
  if dashboard not in dashboards
    return res.redirect "/account/profile"  
    
  if dashboard in ["billing"]
    js = ["dashboard", "card", "fa"]
    res.locals.config.stripe_key = CONFIG.stripe.public
  
  res.render "account/index", {
    js: req.js.renderTags.apply(req.js, js)
    css: req.css.renderTags.apply(req.css, css)
    title: "Account Settings"
    dashboard: "account"
    subdashboard: dashboard
  }
  
  
module.exports.profile = require "./profile"
module.exports.notifications = require "./notifications"
module.exports.billing = require "./billing"
module.exports.password = require "./password"