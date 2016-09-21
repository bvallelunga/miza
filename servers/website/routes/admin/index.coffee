module.exports.get_root = (req, res, next)->
  res.render "admin/index", {
    css: req.css.renderTags "admin", "fa"
    title: "Admin Center"
  }
  

module.exports.reports = access = require "./reports"
module.exports.access = access = require "./access"
module.exports.publishers = require "./publishers"
module.exports.industries = require "./industries"
module.exports.scheduler = require "./scheduler"
module.exports.users = require "./users"