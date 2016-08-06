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
  req.publisher.endpoint = "#{req.publisher.key}.#{req.get("host")}"

  res.render "demo/#{req.params.test or "index"}", {
    publisher: req.publisher
  }