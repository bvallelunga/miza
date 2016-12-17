uglifyJS = require 'uglify-js'
utils = require "../core/utils"
proxy = require "./proxy"


module.exports.carbon = (req, res, next)->
  LIBS.models.Network.find({
    where: {
      slug: "carbon"
    }
  }).then (network)->
    req.script = "carbon"
    req.network = network
    next()


module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")

  LIBS.models.OptOut.count({
    where: {
      ip_address: req.ip or req.ips
    }
  }).then (count)->
    res.render "protect/#{req.script}/script", {
      enabled: req.publisher.coverage_ratio > Math.random() and count == 0
      random_slug: utils.random_slug
      publisher: req.publisher
      network: req.network
      networks: req.publisher.networks.filter (network)->
        return network.is_enabled
    }, (error, code)->
      if error?
        console.error error.stack
        code = ""
      
      if CONFIG.is_dev
        return res.send code
    
      res.send uglifyJS.minify(code, {
        fromString: true
      }).code
      
  .catch next
    

module.exports.proxy = (req, res, next)->
  proxy.path(req.get('host'), req.path, req.decoded_path).then (path)->
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
      
  
  .catch next
      