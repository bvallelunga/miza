module.exports.post = (req, res, next)->
  if req.user.is_demo
    return next "Demo accounts can not be modified."
    
  if req.user.is_admin
    req.publisher.miza_endpoint = req.body.miza_endpoint == "true"
    
  req.publisher.config.coverage = Number(req.body.config_coverage)/100
  req.publisher.config.ad_coverage = 1/Number(req.body.config_ad_coverage)
  req.publisher.config.refresh.interval = Number(req.body.config_refresh)
  req.publisher.config.refresh.enabled = Number(req.body.config_refresh) > 0
  
  req.publisher.update({
    name: req.body.publisher_name
    domain: req.body.publisher_domain
    config: req.publisher.config
    miza_endpoint: req.publisher.miza_endpoint
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next