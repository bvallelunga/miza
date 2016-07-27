module.exports.root = (req, res, next)->
  res.render "landing/index", {
    js: req.js.renderTags "landing"
    css: req.css.renderTags "landing"
  }