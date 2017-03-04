module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range")
  req.data.css.push("date-range")
  req.data.dashboard_width = "medium"
  
  Promise.resolve().then ->
    if not req.subdashboard
      req.data.js.push("data-table")
      req.data.css.push("data-table")
      req.subdashboard = "listing"
      
    else if req.subdashboard == "create" 
      req.data.js.push("modal")
      req.subdashboard = "builder"
      
      return LIBS.models.Industry.listed().then (industries)->
        req.data.industries = industries
      
    else
      req.subdashboard = "analytics"
    
  .then ->
    next() 
     
  .catch next
  
  
module.exports.post_updates = (req, res, next)->
  res.json {
    success: true
  }
  
  
module.exports.post_list = (req, res, next)->
  req.advertiser.getCampaigns().then (campaigns)->
    res.json {
      success: true
      results: campaigns
    }