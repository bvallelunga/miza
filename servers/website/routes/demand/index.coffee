module.exports = DASHBOARDS = {
  campaigns: require "./campaigns"
  campaign:  require "./campaign"
  settings:  require "./settings"
  auth:      require "./auth"
  create:    require "./create"
  billing:   require "./billing"
  members:   require "./members"
  docs:      require "./docs"
}

module.exports.get_root = (req, res, next)->   
  if req.user.advertisers.length == 0
    return res.redirect "/dashboard/demand/new"
    
  res.redirect "/dashboard/demand/#{req.user.advertisers[0].key}/campaigns"
  
  
module.exports.fetch_data = (req, res, next)->
  req.data = {
    js: [ "demand", "dashboard", "fa", "tooltip" ]
    css: [ "demand", "dashboard", "tooltip"  ]
    advertisers: req.user.advertisers
  }
  req.dashboard = req.params.dashboard or null
  req.subdashboard = req.params.subdashboard or null
  
  if not (dashboard = DASHBOARDS[req.dashboard])?
    return res.redirect "/dashboard/demand/#{ req.advertiser.key }/campaigns"
  
  Promise.resolve().then ->  
    if not req.user.is_admin
      return false
      
    LIBS.models.Advertiser.findAll().then (advertisers)->
      req.data.advertisers = advertisers

  .then ->
    dashboard.fetch req, res, next
  

module.exports.get_dashboard = (req, res, next)->
  data = {
    title: "Demand Dashboard"
    type: "demand"
    dashboard: req.dashboard
    subdashboard: req.subdashboard
    dashboard_path: "/dashboard/demand/#{ req.advertiser.key }"
    dashboard_width: ""
  }
  
  for key, value of req.data
    data[key] = value

  data.js = req.js.renderTags.apply(req.js, data.js)
  data.css = req.css.renderTags.apply(req.css, data.css)
  res.render "demand/index", data