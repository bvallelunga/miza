module.exports = (srv)->
  ads_secret = Math.random().toString(33).slice(2)

  return {
    
    website: require("./website")(srv)
    
    ads: {
      app: require("./ads")(srv),
      prefix: "/" + ads_secret
    }
    
    engine: (req, res, next)->
      if req.host.indexOf(CONFIG.ads_server.protected_domain) > -1
        return res.redirect CONFIG.ads_server.denied.redirect
    
      subdomains = req.host.split(".")
    
      if subdomains.length >= 2 and subdomains[0] not in CONFIG.website_subdomains
        req.url =  "/#{ads_secret}/#{req.path.slice(1)}"
        
      next()
    
  }