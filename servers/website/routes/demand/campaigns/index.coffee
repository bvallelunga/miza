module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range")
  req.data.css.push("date-range")
  req.data.dashboard_width = "medium"
  
  if not req.subdashboard
    req.data.js.push("data-table")
    req.data.css.push("data-table")
    req.subdashboard = "listing"
    
  else 
    req.subdashboard = "builder"
  
  next()
  
  
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