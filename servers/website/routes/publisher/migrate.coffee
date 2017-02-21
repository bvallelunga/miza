module.exports.get = (req, res, next)->
  res.render "publisher/migrate", {
    js: req.js.renderTags "publisher"
    css: req.css.renderTags "publisher", "fa"
    title: "Migration Dashboard"
  }