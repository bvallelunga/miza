url     = require "url"
analytics = require "./analytics"
settings = require "./settings"
billing = require "./billing"

module.exports.get_root = (req, res, next)->
  if req.user.publishers.length == 0
    res.redirect "/dashboard/new"
    
  res.redirect "/dashboard/#{req.user.publishers[0].key}/analytics"
  
  
module.exports.get_new = (req, res, next)->
  LIBS.models.Industry.findAll().then (industries)->
    res.render "dashboard/new", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal"
      title: "Create Publisher"
      industries: industries
    }
  
  
module.exports.post_new = (req, res, next)->
  Publisher = LIBS.models.Publisher 
  
  if not req.body.publisher_industry?
    return next "Please select an industry."

  Publisher.create({
    domain: Publisher.get_domain req.body.publisher_domain
    name: req.body.publisher_name
    industry_id: Number req.body.publisher_industry
  }).then (publisher)->
    req.user.addPublisher(publisher).then ->
      res.json {
        success: true
        next: "/dashboard/#{publisher.key}/setup"
      }
    
  .catch next


module.exports.get_dashboard = (req, res, next)->
  js = ["dashboard", "fa"]
  css = ["dashboard", "fa"]
  dashboard = req.params.dashboard
  dashboard_path = "/dashboard/#{req.publisher.key}"
  dashboards = [
    "setup", "analytics", "billing", "settings"
  ]

  if dashboard not in dashboards
    return res.redirect "#{dashboard_path}/analytics"
    
  switch dashboard
    when "setup"
      js.push "code"
      css.push "code"
      
    when "settings"
      js.push "modal", "range-slider"
      css.push "range-slider"

    when "analytics", "billing"
      js.push "dashboard-analytics"
      css.push "dashboard-analytics"
  
  Promise.resolve().then ->
    if dashboard != "settings"
      return null
      
    return LIBS.models.Industry.findAll()
    
  .then (industries)->    
    res.render "dashboard/index", {
      js: req.js.renderTags.apply(req.js, js)
      css: req.css.renderTags.apply(req.css, css)
      title: "Dashboard"
      dashboard_path: dashboard_path
      dashboard: dashboard
      industries: industries
    }
  
  
module.exports.post_settings = settings.post_settings
module.exports.get_analytics_logs = analytics.get_logs
module.exports.get_analytics_metrics = analytics.get_metrics
module.exports.get_billing_logs = billing.get_logs
module.exports.get_billing_metrics = billing.get_metrics
