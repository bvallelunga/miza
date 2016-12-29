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
      abtest = req.publisher.abtest.coverage
      alt_publisher = req.publisher.abtest.alt_publisher
      
      switch req.publisher.product
        when "network" then prefix = "/#{network_secret}"
        when "protect" then prefix = "/#{protect_secret}"
      
      if abtest > Math.random()
        req.url = "#{prefix}/#{req.path.slice(1)}" 
        return next()
        
      LIBS.models.Publisher.findById(alt_publisher).then (publisher)->
        endpoint = publisher.endpoint
        
        if publisher.is_demo
          endpoint = "#{publisher.key}.#{CONFIG.web_server.domain}"
        
        res.redirect "#{req.protocol}://#{endpoint}"
        
      .catch next
    
  }
