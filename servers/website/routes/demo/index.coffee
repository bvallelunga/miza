module.exports.set_user = (req, res, next)->
  req.session.user = LIBS.models.defaults.demo_user.id
  req.user = LIBS.models.defaults.demo_user
  req.publisher = LIBS.models.defaults.demo_user.publishers[0]
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
  req.publisher.endpoint = "#{req.publisher.key}.#{host}"
  
  LIBS.models.Network.findAll().then (networks)->
    networks_dict = {}
    
    for network in networks
      networks_dict[network.slug] = network
  
    res.render "demo/#{if req.params.demo? then "tester" else "demo"}", {
      publisher: req.publisher
      demo: req.params.demo
      css: req.css.renderTags "demo"
      title: "Miza Demo"
      user: req.user
      networks: networks_dict
    }