moment = require "moment"

module.exports.get_root = (req, res, next)->
  if req.query.dashboard?
    return res.redirect "/dashboard/#{req.query.dashboard}/analytics"

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

    when "analytics", "billing"
      js.push "dashboard-analytics", "tooltip"
      css.push "dashboard-analytics", "tooltip"
      
  
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
        owner_id: {
          $ne: LIBS.models.defaults.github_user.id
        }
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
