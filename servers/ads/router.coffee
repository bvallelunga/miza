randomstring = require "randomstring"

module.exports = (srv)->

  network_secret = randomstring.generate(15)

  return {
    
    core: require "./core"
    
    network: {
      prefix: "/#{network_secret}"
      app: require("./network")(srv)
    }
    
    engine: (req, res, next)->
      prefix = ""
      
      switch req.publisher.product
        when "network" then prefix = "/#{network_secret}"
      
      req.url = "#{prefix}/#{req.path.slice(1)}" 
      next()
    
  }
