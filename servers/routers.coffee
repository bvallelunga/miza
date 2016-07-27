module.exports = (srv)->
  sledge_secret = Math.random().toString(33).slice(2)

  return {
    
    website: require("./website")(srv)
    
    sledge: {
      app: require("./sledge")(srv),
      prefix: "/" + sledge_secret
    }
    
    engine: (req, res, next)->
      subdomains = req.host.split(".")
    
      if subdomains.length >= 2 and subdomains[0] != "www"
        req.url =  "/#{sledge_secret}/#{req.path.slice(1)}"
        
      next()
    
  }