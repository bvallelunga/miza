module.exports.fetch = (req, res, next)->
  req.data.dashboard_width = "large"
  req.data.js.push "tooltip", "code"
  req.data.css.push "tooltip", "code"
  next()