module.exports.root = (req, res, next)-> 
  res.render "landing/index", {
    js: req.js.renderTags "landing", "code"
    css: req.css.renderTags "landing", "code"
  }