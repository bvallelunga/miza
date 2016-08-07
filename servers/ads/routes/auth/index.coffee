module.exports.has_publisher = (req, res, next)->
  domains = req.host.split(".").slice(0, -1)
  
  if domains.length == 0
    res.redirect CONFIG.ads_redirect
  
  LIBS.models.Publisher.findOne({
    where: {      
      key: domains[0]
    }
  }).then (publisher)->
    if not publisher?
      return res.redirect CONFIG.ads_redirect
    
    req.publisher = publisher
    next()
    
  .catch next