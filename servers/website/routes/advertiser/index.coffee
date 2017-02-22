module.exports.get_root = (req, res, next)->
  res.render "advertiser/index", {
    js: req.js.renderTag "advertiser"
    css: req.css.renderTags "advertiser"
    title: "Advertiser Dashboard"
  }