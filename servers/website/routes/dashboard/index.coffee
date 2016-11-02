moment = require "moment"

module.exports.get_root = (req, res, next)->
  if req.query.id?
    return LIBS.models.Publisher.findOne({
      where: {
        id: req.query.id
      }
    }).then (publisher)->
      if not publisher?
        return res.redirect "/dashboard"
        
      res.redirect "/dashboard/#{publisher.key}/#{req.query.page or "analytics"}"

  if req.user.publishers.length == 0
    return res.redirect "/dashboard/new"
    
  res.redirect "/dashboard/#{req.user.publishers[0].key}/analytics"
  


module.exports.get_dashboard = (req, res, next)->
  js = ["dashboard"]
  css = ["dashboard", "fa"]
  dashboard = req.params.dashboard
  dashboard_path = "/dashboard/#{req.publisher.key}"
  dashboards = [
    "setup", "analytics", "billing", "members", "settings"
  ]
  ads_domain = CONFIG.ads_server.domain
  dashboard_title = (dashboard.split(' ').map (word) -> 
    return word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

  if dashboard not in dashboards
    return res.redirect "#{dashboard_path}/analytics"  
  
  if req.publisher.is_demo
    ads_domain = req.get("host")
  
  switch dashboard
    when "setup"
      js.push "code"
      css.push "code"
      
    when "members", "settings"
      js.push "modal", "range-slider"
      css.push "range-slider"

    when "analytics"
      js.push "dashboard-analytics", "tooltip", "date-range"
      css.push "tooltip", "date-range"
      
    when "billing"
      js.push "dashboard-billing", "tooltip"
      css.push "tooltip"
      
  
  Promise.resolve().then ->
    if dashboard != "setup"
      return Promise.resolve()
      
    res.locals.networks = {}
    
    for network in LIBS.models.defaults.networks
      res.locals.networks[network.slug] = network
  
  .then ->
    if dashboard != "members"
      return {}
      
    Promise.props {
      members: req.publisher.getMembers()
      invites: req.publisher.getInvites()
    }
    
  .then (props)->
    if not req.user.is_admin
      return props
      
    LIBS.models.Publisher.findAll({
      where: {
        is_activated: true
      }
      order: [
        ['fee', 'DESC']
        ['name', 'ASC']
      ]
    }).then (publishers)->
      props.publishers = publishers
      return props
  
  .then (props)->
    res.render "dashboard/index", {
      js: req.js.renderTags.apply(req.js, js)
      css: req.css.renderTags.apply(req.css, css)
      title: "#{dashboard_title} Dashboard"
      dashboard_path: dashboard_path
      dashboard: dashboard
      ads_domain: ads_domain
      guide: req.query.new_publisher?
      changelog: true
      props: props
      billed_on: moment(LIBS.helpers.past_date "month", null, 1).format("MMM D") 
    }
    
  .catch next
  
  
module.exports.create = require "./create"
module.exports.settings = require "./settings"
module.exports.analytics = require "./analytics"
module.exports.billing = require "./billing"
module.exports.members = require "./members"
