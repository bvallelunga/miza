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


module.exports.get_publisher = (req, res, next)->
  dashboard_path = "/dashboard/#{req.publisher.key}"
  dashboards = [
    "setup", "analytics", "settings"
  ]

  if req.params.dashboard not in dashboards
    return res.redirect "#{dashboard_path}/setup"

  res.render "dashboard/index", {
    js: req.js.renderTags "dashboard", "code", "fa", "modal"
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
  
