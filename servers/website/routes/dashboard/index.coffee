url = require('url')

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
  domain = url.parse req.body.publisher_domain

  LIBS.models.Publisher.create({
    domain: "#{domain.hostname || domain.pathname}#{if domain.port? then (":" + domain.port) else "" }"
    name: req.body.publisher_name
  }).then (publisher)->
    return req.user.addPublisher publisher
  
  .then ->
    res.json {
      success: true
      next: "/dashboard"
    }
    
  .catch next


module.exports.get_publisher = (req, res, next)->
  dashboard_path = "/dashboard/#{req.publisher.key}"
  dashboards = [
    "setup", "analytics", "account", "settings"
  ]

  if req.params.dashboard not in dashboards
    return res.redirect "#{dashboard_path}/setup"

  res.render "dashboard/index", {
    js: req.js.renderTags "dashboard", "code", "fa"
    css: req.css.renderTags "dashboard", "code", "fa"
    title: "Dashboard"
    dashboard_path: dashboard_path
    dashboard: req.params.dashboard
    publisher: req.publisher
    intercom: {
      company: {
        id: req.publisher.id
        name: req.publisher.name
      }
    }
  }