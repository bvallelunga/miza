module.exports.get_root = (req, res, next)->
  res.render "landing/demo/index", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Live Demo"
  }


module.exports.get_miza = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  product = req.params.product or "network"
  req.publisher = LIBS.models.defaults.demo_publishers[product]
  req.publisher.endpoint = "#{req.publisher.key}.#{host}"
  
  res.render "landing/demo/tester", {
    publisher: req.publisher
    demo: req.params.demo
    product: product
    user: LIBS.models.defaults.demo_user
  }