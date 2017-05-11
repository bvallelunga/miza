module.exports.get_root = (req, res, next)->
  res.render "landing/supply/home", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Publisher"
  }


module.exports.get_monetize = (req, res, next)->
  res.render "landing/supply/monetize", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Monetize"
  }  


module.exports.get_demo = (req, res, next)->
  res.render "landing/supply/demo", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Live Demo"
  }


module.exports.get_demo_ad = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  publisher = LIBS.models.defaults.demo_publisher
  publisher.endpoint = "#{publisher.key}.#{host}"
  
  res.render "landing/supply/demo/tester", {
    publisher: publisher
    user: LIBS.models.defaults.demo_user
  }