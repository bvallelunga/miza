module.exports.get = (req, res, next)->
  res.render "admin/scheduler", {
    css: req.css.renderTags "admin"
    title: "Admin Scheduler"
  }