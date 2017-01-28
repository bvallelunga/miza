module.exports.get_root = (req, res, next)->
  res.render "landing/demo/index", {
    js: req.js.renderTags "landing"
    css: req.css.renderTags "landing", "fa"
    title: "Demo"
    user: LIBS.models.defaults.demo_user
  }


module.exports.get_miza = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  req.publisher = LIBS.models.defaults.demo_publishers.network
  req.publisher.endpoint = "#{req.publisher.key}.#{host}"
  
  res.render "landing/demo/tester", {
    publisher: req.publisher
    demo: req.params.demo
    title: "Demo"
    user: LIBS.models.defaults.demo_user
  }