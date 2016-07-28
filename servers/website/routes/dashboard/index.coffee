module.exports.get_root = (req, res, next)->
  dashboards = [
    "setup", "analytics", "account", "settings"
  ]

  if req.params.dashboard not in dashboards
    return res.redirect "/dashboard/setup"

  res.render "dashboard/index", {
    js: req.js.renderTags "dashboard", "code", "fa"
    css: req.css.renderTags "dashboard", "code", "fa"
    title: "Dashboard"
    dashboard: req.params.dashboard
  }