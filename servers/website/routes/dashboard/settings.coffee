module.exports.post_settings = (req, res, next)->
  if not req.body.publisher_industry?
    return next "Please select an industry."
  
  req.publisher.update({
    name: req.body.publisher_name
    domain: LIBS.models.Publisher.get_domain req.body.publisher_domain
    coverage_ratio: Number req.body.coverage
    industry_id: Number req.body.publisher_industry
  }).then ->
    res.json {
      success: true
      next: req.path
    }
  
  .catch next