module.exports.get = (req, res, next)->
  res.render "publisher/migrate", {
    js: req.js.renderTags "publisher", "modal"
    css: req.css.renderTags "publisher", "fa", "landing"
    title: "Migration Dashboard"
  }