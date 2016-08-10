module.exports.post_settings = (req, res, next)->  
  req.publisher.update({
    name: req.body.publisher_name
    domain: req.body.publisher_domain
    coverage_ratio: Number req.body.coverage
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next