module.exports.post = (req, res, next)->
  if req.user.is_demo
    return next "Demo accounts can not be modified."

  req.publisher.update({
    abtest: {
      coverage: Number req.body.coverage
      alt_publisher: Number req.body.alt_publisher
    }
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next