module.exports.root = (req, res, next)->
  res.render "homepage/index", {
    js: req.js.renderTags "home"
    css: req.css.renderTags "home"
  }