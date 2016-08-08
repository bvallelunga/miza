module.exports.publisher = (req, res, next)->
  LIBS.models.Publisher.findOne({
    where: {
      is_demo: true
    }
  }).then (publisher)->
    req.publisher = publisher
    next()
    
  .catch next


module.exports.get_root = (req, res, next)->
  host = req.get("host").split(".").slice(-2).join(".")
  req.publisher.endpoint = "#{req.publisher.key}.#{host}"

  res.render "demo/#{if req.params.demo? then "demo" else "index"}", {
    publisher: req.publisher
    demo: req.params.demo
  }