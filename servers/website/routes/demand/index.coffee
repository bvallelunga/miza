ADVERTISER = 1
DASHBOARDS = {
  "dashboard": [
    "analytics", "payments"
  ]
  "campaigns": []
  "units": []
  "settings": []
}

module.exports.get_root = (req, res, next)->   
  res.redirect "/demand/#{ ADVERTISER }/dashboard/analytics"


module.exports.get_dashboard = (req, res, next)->
  dashboard = req.params.dashboard or null
  subdashboard = req.params.subdashboard or null
  
  if not DASHBOARDS[dashboard]?
    return res.redirect "/demand/#{ ADVERTISER }/dashboard/analytics"
  
  else if DASHBOARDS[dashboard].length > 0 and DASHBOARDS[dashboard].indexOf(subdashboard) == -1
    return res.redirect "/demand/#{ ADVERTISER }/#{dashboard}/#{DASHBOARDS[dashboard][0]}"

  res.render "demand/index", {
    js: req.js.renderTags "demand"
    css: req.css.renderTags "demand", "fa"
    title: "Demand Dashboard"
    type: "demand"
    dashboard: dashboard
    subdashboard: subdashboard
    dashboard_path: "/demand/#{ ADVERTISER }"
  }