randomstring = require "randomstring"

module.exports = (srv)->

  protect_secret = randomstring.generate(15)
  network_secret = randomstring.generate(15)

  return {
    
    core: require "./core"
    
    protect: {
      prefix: "/#{protect_secret}"
      app: require("./protect")(srv)
    }
    
    network: {
      prefix: "/#{network_secret}"
      app: require("./network")(srv)
    }
    
    engine: (req, res, next)->
      prefix = ""
      
      switch req.publisher.product
        when "network" then prefix = "/#{network_secret}"
        when "protect" then prefix = "/#{protect_secret}"
      
      req.url = "#{prefix}/#{req.path.slice(1)}" 
      next()
    
  }
