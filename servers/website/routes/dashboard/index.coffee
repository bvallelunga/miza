url     = require 'url'
numeral = require "numeral"

module.exports.get_root = (req, res, next)->
  if req.user.publishers.length == 0
    res.redirect "/dashboard/new"
    
  res.redirect "/dashboard/#{req.user.publishers[0].key}/setup"
  
  
module.exports.get_new = (req, res, next)->
  res.render "dashboard/new", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Create Publisher Account"
  }
  
  
module.exports.post_new = (req, res, next)->
  Publisher = LIBS.models.Publisher 

  Publisher.create({
    domain: Publisher.get_domain req.body.publisher_domain
    name: req.body.publisher_name
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
    "setup", "analytics", "settings"
  ]

  if dashboard not in dashboards
    return res.redirect "#{dashboard_path}/setup"
    
  switch dashboard
    when "setup"
      js.push "code"
      css.push "code"
      
    when "settings"
      js.push "modal"
  
    
    when "analytics"
      js.push "dashboard-analytics"
      css.push "dashboard-analytics"
  
  res.render "dashboard/index", {
    js: req.js.renderTags.apply(req.js, js)
    css: req.css.renderTags.apply(req.css, css)
    title: "Dashboard"
    dashboard_path: dashboard_path
    dashboard: dashboard
    publisher: req.publisher
    intercom: {
      company: {
        id: req.publisher.id
        name: req.publisher.name
      }
    }
  }
  
  
module.exports.post_settings = (req, res, next)->
  req.publisher.update({
    name: req.body.publisher_name
    domain: LIBS.models.Publisher.get_domain req.body.publisher_domain
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next
  
  
module.exports.get_analytics_logs = (req, res, next)->
  month_ago = new Date()
  month_ago.setMonth(month_ago.getMonth()-1)

  req.publisher.getEvents({ 
    limit: 100 
    attributes: [ "ip_address", "protected", "created_at", "type" ]
    where: {
      type: {
        $ne: "asset" 
      }
      created_at: {
        $gte: month_ago
      }
    }
    order: [
      ['created_at', 'DESC'],
    ]
  }).then (events)->
    res.json(events)
    
  .catch next
  
  
module.exports.get_analytics_metrics = (req, res, next)->
  month_ago = new Date()
  month_ago.setMonth(month_ago.getMonth()-1)
  
  Promise.props({
    all: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        created_at: {
          $gte: month_ago
        }
      }
    })
    all_clicks: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        type: "click"
        created_at: {
          $gte: month_ago
        }
      }
    })
    all_impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        type: "impression"
        created_at: {
          $gte: month_ago
        }
      }
    })
    blocked: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        created_at: {
          $gte: month_ago
        }
      }
    })
    impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "impression"
        created_at: {
          $gte: month_ago
        }
      }
    })
    clicks: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "click"
        created_at: {
          $gte: month_ago
        }
      }
    })
    assets: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "asset"
        created_at: {
          $gte: month_ago
        }
      }
    })
  }).then (props)->  
    res.json {
      impressions: numeral(props.impressions).format("0a")
      clicks: numeral(props.clicks).format("0a")
      assets: numeral(props.assets).format("0a")
      blocked: numeral(props.blocked/(props.all or 1)).format("0.0%")
      ctr: numeral(props.all_clicks/(props.all_impressions or 1)).format("0.0%")
    }
  
  
  
  
  
