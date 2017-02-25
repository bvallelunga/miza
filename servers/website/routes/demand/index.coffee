ADVERTISER = 1
module.exports = DASHBOARDS = {
  analytics: require "./analytics"
  campaigns: require "./campaigns"
  units:     require "./units"
  settings:  require "./settings"
}

module.exports.get_root = (req, res, next)->   
  res.redirect "/demand/#{ ADVERTISER }/analytics"
  
  
module.exports.fetch_data = (req, res, next)->
  req.data = {
    js: [ "demand", "dashboard" ]
    css: [ "demand", "fa", "dashboard" ]
  }
  req.dashboard = req.params.dashboard or null
  req.subdashboard = req.params.subdashboard or null
  
  if not (dashboard = DASHBOARDS[req.dashboard])?
    return res.redirect "/demand/#{ ADVERTISER }/analytics"
    
  dashboard.fetch req, res, next
  

module.exports.get_dashboard = (req, res, next)->
  data = {
    title: "Demand Dashboard"
    type: "demand"
    dashboard: req.dashboard
    subdashboard: req.subdashboard
    dashboard_path: "/demand/#{ ADVERTISER }"
    dashboard_width: ""
  }
  
  for key, value of req.data
    data[key] = value

  data.js = req.js.renderTags.apply(req.js, data.js)
  data.css = req.css.renderTags.apply(req.css, data.css)
  res.render "demand/index", data