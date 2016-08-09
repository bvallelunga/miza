module.exports.set_user = (req, res, next)->
  if req.user?
    if req.user.email != "demo@miza.io"
      return res.redirect "/dashboard" 
      
    else
      return res.redirect "/demo/select"


  LIBS.models.User.findOne({
    where: {
      email: "demo@miza.io"
    }
  }).then (user)->
    req.session.user = user.id
    res.redirect "/demo/select"
    
  .catch next
  
  
module.exports.set_publisher = (req, res, next)->
  req.publisher = req.user.publishers[0]
  next()


module.exports.get_root = (req, res, next)->
  res.render "demo/index", {
    css: req.css.renderTags "admin", "fa"
    title: "Demo Center"
  }
  
  
module.exports.get_wordpress = (req, res, next)->
  res.redirect "http://demo.miza.io"


module.exports.get_miza = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  req.publisher.endpoint = "#{req.publisher.key}.#{host}"

  res.render "demo/#{if req.params.demo? then "tester" else "demo"}", {
    publisher: req.publisher
    demo: req.params.demo
    css: req.css.renderTags "demo"
    title: "Miza Demo"
  }