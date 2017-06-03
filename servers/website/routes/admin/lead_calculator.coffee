module.exports.get = (req, res, next)->
  res.render "admin/lead_calculator", {
    js: req.js.renderTags "modal", "admin-lead-calculator", "fa"
    css: req.css.renderTags "modal", "admin"
    title: "Admin Lead Calculator"
    dashboard: "admin"
  }