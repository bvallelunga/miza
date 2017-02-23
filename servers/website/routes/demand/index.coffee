module.exports.get_root = (req, res, next)->
  res.render "demand/index", {
    js: req.js.renderTags "demand", "dashboard"
    css: req.css.renderTags "demand", "dashboard", "fa"
    title: "Demand Dashboard"
  }