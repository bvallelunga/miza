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
    "setup", "analytics", "members", "settings"
  ]
  ads_domain = CONFIG.ads_server.domain
  dashboard_title = (dashboard.split(' ').map (word) -> 
    return word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

  if req.publisher.product == "protect"
    dashboards.push "abtest", "billing"
    
  if req.publisher.product == "network"
    dashboards.push "payouts"

  if dashboard not in dashboards
    return res.redirect "#{dashboard_path}/analytics"  
  
  if req.publisher.is_demo
    ads_domain = req.hostname
  
  switch dashboard
    when "setup"
      js.push "code"
      css.push "code"
      
    when "members", "settings", "abtest"
      js.push "modal", "range-slider"
      css.push "range-slider"

    when "analytics"
      js.push "dashboard-analytics", "tooltip", "date-range"
      css.push "tooltip", "date-range"
      
    when "billing", "payouts"
      js.push "dashboard-billing", "tooltip"
      css.push "tooltip"
      
  
  Promise.resolve().then ->
    if not (dashboard == "payouts" and req.publisher.product == "network")
      return Promise.resolve()
      
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
  
    res.render "dashboard/index", {
      js: req.js.renderTags.apply(req.js, js)
      css: req.css.renderTags.apply(req.css, css)
      title: "#{dashboard_title} Dashboard"
      dashboard_path: dashboard_path
      dashboard: dashboard
      ads_domain: ads_domain
      guide: show_guide
      changelog: true
      props: props
      billed_on: moment(LIBS.helpers.past_date "month", null, 1).add(4, "day").format("MMM D") 
      payout_on: moment(LIBS.helpers.past_date "month", null, 1).add(10, "day").format("MMM D") 
    }
    
  .catch next
  
  
module.exports.create = require "./create"
module.exports.abtest = require "./abtest"
module.exports.settings = require "./settings"
module.exports.analytics = require "./analytics"
module.exports.billing = require "./billing"
module.exports.members = require "./members"
