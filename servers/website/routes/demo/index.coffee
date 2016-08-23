module.exports.set_user = (req, res, next)->
  Promise.resolve().then ->
    if req.user? and req.user.email == "demo@miza.io"
      return req.user
  
    LIBS.models.User.findOne({
      where: {
        email: "demo@miza.io"
      }
      include: [{
        model: LIBS.models.Publisher
        as: "publishers"
      }]
    }).then (user)->
      req.session.user = user.id
      req.user = user
      return user
  
  .then (user)->
    req.publisher = user.publishers[0]
    next()
    
  .catch next


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

  res.render "demo/#{if req.params.demo? then "tester" else "demo"}", {
    publisher: req.publisher
    demo: req.params.demo
    css: req.css.renderTags "demo"
    title: "Miza Demo"
    user: req.user
  }