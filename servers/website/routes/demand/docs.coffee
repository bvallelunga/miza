module.exports.fetch = (req, res, next)->
  req.data.dashboard_width = "large"
  req.data.js.push "tooltip", "code"
  req.data.css.push "tooltip", "code"
  next()
  
  
module.exports.unauthorized = (req, res, next)->
  res.render "demand/index", {
    title: "Demand API Docs"
    type: "none"
    user: null
    advertiser: null
    dashboard: "docs"
    subdashboard: ""
    dashboard_path: "/"
    dashboard_width: "large"
    js: req.js.renderTags "demand", "dashboard", "fa", "tooltip", "code"
    css: req.css.renderTags "demand", "dashboard", "tooltip", "code"
  }