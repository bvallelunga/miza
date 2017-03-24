moment = require "moment"

module.exports.get_root = (req, res, next)->  
  if req.user.publishers.length == 0
    return res.redirect "/supply/new"
    
  res.redirect "/supply/#{req.user.publishers[0].key}/analytics"


module.exports.get_dashboard = (req, res, next)->
  js = ["dashboard", "supply", "fa"]
  css = ["dashboard", "supply"]
  dashboard = req.params.dashboard
  dashboard_path = "/supply/#{req.publisher.key}"
  dashboards = [
    "setup", "analytics", "members", "settings", "payouts"
  ]
  dashboard_size = ""
  ads_domain = CONFIG.ads_server.domain
  dashboard_title = (dashboard.split(' ').map (word) -> 
    return word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

  if dashboard not in dashboards
    return res.redirect "#{dashboard_path}/analytics"  
  
  if req.publisher.is_demo
    ads_domain = req.hostname
  
  switch dashboard
    when "setup"
      js.push "code"
      css.push "code"
      
    when "members"
      dashboard_size = "medium"
      js.push "modal", "range-slider", "tooltip"
      css.push "range-slider", "tooltip"
      
    when "settings"
      js.push "modal", "range-slider", "tooltip"
      css.push "range-slider", "tooltip"

    when "analytics"
      js.push "tooltip", "keen", "date-range"
      css.push "tooltip", "keen", "date-range"
      
  
  Promise.resolve().then ->
    req.publisher.transfers = []
  
    if dashboard != "payouts"
      return Promise.resolve()
      
    dashboard_size = "large"
    req.publisher.getTransfers({
      include: [{
        model: LIBS.models.Payout
        as: "payout"
      }]
    }).then (transfers)->
      req.publisher.transfers = transfers
  
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
        $or: [
          {
            is_activated: true
          }, 
          {
            owner_id: req.user.id
          }
        ]
      }
      order: [
        ['fee', 'DESC']
        ['name', 'ASC']
      ]
    }).then (publishers)->
      props.publishers = publishers
      return props
  
  .then (props)->
    show_guide = req.query.new_publisher? or req.session.new_publisher
    req.session.new_publisher = false
  
    res.render "supply/index", {
      js: req.js.renderTags.apply(req.js, js)
      css: req.css.renderTags.apply(req.css, css)
      title: "#{dashboard_title} Dashboard"
      dashboard_path: dashboard_path
      dashboard: dashboard
      ads_domain: ads_domain
      guide: show_guide
      changelog: true
      props: props
      type: "supply"
      dashboard_size: dashboard_size
      publisher: req.publisher
      config: {
        publisher: req.publisher.key
        keen: {
          projectId: CONFIG.keen.projectId
          readKey: req.publisher.config.keen
        }
      }
    }
    
  .catch next
  

module.exports.auth = require "./auth"
module.exports.create = require "./create"
module.exports.analytics = require "./analytics"
module.exports.settings = require "./settings"
module.exports.members = require "./members"
