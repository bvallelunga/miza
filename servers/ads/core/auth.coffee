cookieParser = require 'cookie-parser'

module.exports.has_publisher = (req, res, next)->
  domains = req.hostname.split(".").slice(0, -1)
  
  if domains.length == 0
    return res.end CONFIG.ads_server.denied.message
  
  LIBS.models.Publisher.findOne({
    where: {      
      key: domains[0]
    }
  }).then (publisher)->  
    if not publisher?
      return res.end CONFIG.ads_server.denied.message
    
    req.publisher = publisher
    cookieParser("#{publisher.key}_#{publisher.created_at}")(req, res, next)
    
  .catch next
  
  
module.exports.has_opted_out = (req, res, next)->    
  LIBS.models.OptOut.count({
    where: {
      ip_address: req.ip or req.ips
    }
  }).then (count)->
    req.miza_enabled = count == 0 and req.signedCookies.optout != "true"
    next()
    
  .catch next