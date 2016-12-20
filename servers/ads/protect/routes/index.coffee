uglifyJS = require 'uglify-js'
proxy = require "./proxy"
randomstring = require "randomstring"


module.exports.carbon = (req, res, next)->
  req.script = "carbon"
  next()


module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")

  res.render "#{req.script}/script", {
    enabled: req.publisher.coverage_ratio > Math.random() and req.miza_enabled
    random_slug: randomstring.generate(15)
    publisher: req.publisher
  }, (error, code)->
    if error?
      console.error error.stack
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
      return proxy.modifier data, req.publisher, req.query
        
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
      })
      
  
  .catch next
      