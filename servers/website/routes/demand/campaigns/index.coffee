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
      req.data.dashboard_width = "small"
      
      return LIBS.models.Industry.findAll({
        where: {
          private: false
        }
      }).then (industries)->
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
  res.json {
    success: true
    results: [
      {
        id: 3
        name: "Test"
        status: "In Review"
        budget: 10
        impressions: 1,500
        clicks: 50
        spend: 6.77
      },
      {
        id: 10
        name: "ABC"
        status: "In Review"
        budget: 10
        impressions: 1,500
        clicks: 50
        spend: 6.77
      }
    ]
  }