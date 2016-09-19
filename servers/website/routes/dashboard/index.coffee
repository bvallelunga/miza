moment = require "moment"

module.exports.get_root = (req, res, next)->
  if req.query.dashboard?
    return res.redirect "/dashboard/#{req.query.dashboard}/analytics"

  if req.user.publishers.length == 0
    return res.redirect "/dashboard/new"
    
  res.redirect "/dashboard/#{req.user.publishers[0].key}/analytics"
  


module.exports.get_dashboard = (req, res, next)->
  js = ["dashboard", "fa"]
  css = ["dashboard", "fa"]
  dashboard = req.params.dashboard
  dashboard_path = "/dashboard/#{req.publisher.key}"
  dashboards = [
    "setup", "analytics", "billing", "settings"
  ]
  dashboard_title = (dashboard.split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '
  ads_domain = CONFIG.ads_server.domain
  billed_on = ""

  if dashboard not in dashboards
    return res.redirect "#{dashboard_path}/analytics"  
  
  if req.publisher.is_demo
    ads_domain = req.get("host")
  
  switch dashboard
    when "setup"
      js.push "code"
      css.push "code"
      
    when "settings"
      js.push "modal", "range-slider"
      css.push "range-slider"

    when "analytics", "billing"
      js.push "dashboard-analytics", "tooltip"
      css.push "dashboard-analytics", "tooltip"
  
  res.render "dashboard/index", {
    js: req.js.renderTags.apply(req.js, js)
    css: req.css.renderTags.apply(req.css, css)
    title: "#{dashboard_title} Dashboard"
    dashboard_path: dashboard_path
    dashboard: dashboard
    ads_domain: ads_domain
    guide: req.query.new_publisher?
    changelog: true
    billed_on: moment(LIBS.helpers.past_date "month", null, 1).format("MMM D") 
  }
  
  
module.exports.create = require "./create"
module.exports.settings = require "./settings"
module.exports.analytics = require "./analytics"
module.exports.billing = require "./billing"
