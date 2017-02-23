module.exports.get_root = (req, res, next)->
  res.render "admin/index", {
    css: req.css.renderTags "admin", "fa"
    title: "Admin Center"
    dashboard: "admin"
  }
  

module.exports.invites = require "./invites"
module.exports.publishers = require "./publishers"
module.exports.industries = require "./industries"
module.exports.scheduler = require "./scheduler"
module.exports.users = require "./users"
module.exports.emails = require "./emails"
module.exports.payouts = require "./payouts"