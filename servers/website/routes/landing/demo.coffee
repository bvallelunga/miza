module.exports.get_root = (req, res, next)->
  res.render "landing/demo/index", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Live Demo"
  }


module.exports.get_miza = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  publisher = LIBS.models.defaults.demo_publisher
  publisher.endpoint = "#{publisher.key}.#{host}"
  
  res.render "landing/demo/tester", {
    publisher: publisher
    user: LIBS.models.defaults.demo_user
  }