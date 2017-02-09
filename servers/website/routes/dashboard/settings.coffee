module.exports.post = (req, res, next)->
  if req.user.is_demo
    return next "Demo accounts can not be modified."
    
  
  req.publisher.config.coverage = Number(req.body.config_coverage)/100
  req.publisher.config.refresh = {
    enabled: Number(req.body.config_refresh) > 10
    interval: Number req.body.config_refresh
  }

  req.publisher.update({
    name: req.body.publisher_name
    domain: req.body.publisher_domain
    config: req.publisher.config
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next