module.exports.has_publisher = (req, res, next)->
  domains = req.host.split(".").slice(0, -1)
  
  if domains.length == 0
    res.redirect CONFIG.ads_redirect
  
  LIBS.models.Publisher.findOne({
    where: {      
      key: domains[0]
    }
    include: [{
      model: LIBS.models.Network
      as: "networks"
    }]
  }).then (publisher)->
    if not publisher?
      return res.redirect CONFIG.ads_redirect
    
    req.publisher = publisher
    next()
    
  .catch next
  
  
module.exports.has_network = (req, res, next)->
  network_id = Number req.query.network
  
  for network in req.publisher.networks
    if network.id == network_id
      req.network = network
      return next()
      
  return res.redirect CONFIG.ads_redirect
