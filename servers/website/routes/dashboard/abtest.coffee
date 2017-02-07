module.exports.post = (req, res, next)->
  if req.user.is_demo
    return next "Demo accounts can not be modified."

  req.publisher.config.abtest = {
    coverage: Number(req.body.coverage)/100
    alt_publisher: Number req.body.alt_publisher
  }

  req.publisher.update({
    config: req.publisher.config
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next