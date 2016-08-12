request = require "request"
uglify = require "uglify-js"
script = require "./script"
proxy = require "./proxy"


module.exports.ping = (req, res, next)->
  res.end script.pixel_tracker
  
  LIBS.models.Event.generate req, {
    type: "ping"
    publisher: req.publisher
  }
  
module.exports.impression = (req, res, next)->
  res.end script.pixel_tracker
  
  LIBS.models.Event.generate req, {
    type: "impression"
    publisher: req.publisher
    network: req.network
  }


module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")

  res.render "script", {
    enabled: req.publisher.coverage_ratio > Math.random() 
    random_slug: script.random_slug
    publisher: req.publisher
    networks: req.publisher.networks.filter (network)->
      return network.is_enabled
  }, (error, code)->
    if error?
      console.error error
    
    if not CONFIG.isProd
      return res.send code
  
    res.send uglify.minify(code, {
      fromString: true
    }).code
    

module.exports.proxy = (req, res, next)->
  proxy.path(req.get('host'), req.path).then (path)->
    return proxy.downloader path, req.query, req.headers
    
  .then (data)->  
    if data.media == "asset" and not data.cached
      return proxy.modifier data, req.publisher, req.network
        
    return data
    
  .then (data)-> 
    if data.media == "link"
      res.redirect data.href
      
    else if data.media == "image"
      res.end data.content, "binary"
      
    else
      res.send data.content
      
    return data
      
  .then (data)->
    LIBS.redis.set data.key, JSON.stringify(data)
    LIBS.models.Event.generate req, {
      type: if data.media == "link" then "click" else "asset" 
      asset_url: data.url
      publisher: req.publisher
      network: req.network
    }
