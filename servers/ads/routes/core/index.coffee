request = require "request"
uglifyJS = require 'uglify-js'
script = require "./script"
proxy = require "./proxy"


module.exports.check = (req, res, next)->
  res.end req.publisher.key


module.exports.ping = (req, res, next)->
  res.end script.pixel_tracker
  
  LIBS.models.Event.queue req, {
    type: "ping"
    publisher: req.publisher
  }

  
module.exports.impression = (req, res, next)->
  res.end script.pixel_tracker
  
  LIBS.models.Event.queue req, {
    type: "impression"
    publisher: req.publisher
    network: req.network
  }


module.exports.carbon = (req, res, next)->
  req.script = "carbon"
  next()


module.exports.script = (req, res, next)->
  script = req.script or "v1"

  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")

  LIBS.models.OptOut.count({
    where: {
      ip_address: req.ip or req.ips
    }
  }).then (count)->
    res.render "#{script}/script", {
      enabled: req.publisher.coverage_ratio > Math.random() and count == 0
      random_slug: script.random_slug
      publisher: req.publisher
      networks: req.publisher.networks.filter (network)->
        return network.is_enabled
    }, (error, code)->
      if error?
        console.error error
        code = ""
      
      if CONFIG.is_dev
        return res.send code
    
      res.send uglifyJS.minify(code, {
        fromString: true
      }).code
    

module.exports.proxy = (req, res, next)->
  proxy.path(req.get('host'), req.path).then (path)->
    return proxy.downloader path, req.query, req.headers
    
  .then (data)->   
    if data.media == "asset" and not data.cached
      return proxy.modifier data, req.publisher, req.network, req.query
        
    return data
    
  .then (data)-> 
    if data.media == "link"
      res.redirect data.href
      
    else 
      res.set "Content-Type", data.content_type

      if data.media == "binary"
        res.end data.content, "binary"
      
      else
        res.send data.content
      
    return data
      
  .then (data)->
    if data.to_cache
      LIBS.redis.set data.key, JSON.stringify data
    
    if data.media == "link"
      LIBS.models.Event.queue(req, {
        type: "click"
        asset_url: data.href
        publisher: req.publisher
        network: req.network
      })
      