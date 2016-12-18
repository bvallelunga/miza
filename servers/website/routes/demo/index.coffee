module.exports.set_user = (req, res, next)->
  req.session.user = LIBS.models.defaults.demo_user.id
  req.user = LIBS.models.defaults.demo_user
  next()


module.exports.get_root = (req, res, next)->
  res.render "demo/index", {
    css: req.css.renderTags "admin", "fa"
    title: "Demo Center"
    user: req.user
  }
  
  
module.exports.get_wordpress = (req, res, next)->
  res.redirect "http://demo.miza.io"


module.exports.get_miza = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  req.publisher = LIBS.models.defaults.demo_publishers[req.params.product]
  req.publisher.endpoint = "#{req.publisher.key}.#{host}"
  
  res.render "demo/#{if req.params.demo? then "tester" else "demo"}", {
    publisher: req.publisher
    product: req.params.product
    demo: req.params.demo
    css: req.css.renderTags "demo"
    title: "Miza Demo"
    user: req.user
  }