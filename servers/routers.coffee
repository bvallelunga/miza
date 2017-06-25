publicIP = require 'public-ip'

module.exports = (srv)->
  ads_secret = Math.random().toString(33).slice(2)

  return {
    
    website: {
      app: require("./website")(srv)
    }
    
    ads: {
      app: require("./ads")(srv),
      prefix: "/#{ads_secret}"
    }
    
    ip: (req, res, next)->
      Promise.resolve().then ->
        if CONFIG.is_local
          return publicIP.v4()
      
        return req.headers["CF-Connecting-IP"] or req.ip or req.ips
      
      .then (ip)-> 
        req.ip_address = ip
        next()
        
      .catch next
    
    engine: (req, res, next)->
      domains = req.hostname.split(".")
      slice = if domains.slice(-1)[0] == "localhost" then -1 else -2
      domains = domains.slice(0, slice)

      if CONFIG.pipeline == "localhost" and req.hostname.indexOf(CONFIG.ngrok) > -1
        return next()
            
      if domains.length == 0 and req.hostname.indexOf(CONFIG.ads_server.domain) > -1
        return res.redirect CONFIG.ads_server.denied.redirect
    
      if domains.length > 0 and domains[0] not in CONFIG.website_subdomains
        req.url = "/#{ads_secret}/#{req.path.slice(1)}"
        
      next()
    
  }