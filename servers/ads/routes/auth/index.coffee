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
    
    req.ip_address = real_ip req
    req.publisher = publisher
    console.log req.ip_address
    next()
    
  .catch next
  
  
real_ip = (req)->
  ipAddr = req.headers["x-forwarded-for"]
  
  if ipAddr
    list = ipAddr.split(",");
    ipAddr = list[list.length-1]
    
  else 
    ipAddr = req.connection.remoteAddress
    
  return ipAddr