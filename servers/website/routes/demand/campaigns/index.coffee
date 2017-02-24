module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range", "data-table")
  req.data.css.push("date-range", "data-table")
  req.data.dashboard_width = "medium"
  
  next()