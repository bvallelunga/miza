request = require "request"
uglify = require "uglify-js"
script = require "./script"
proxy = require "./proxy"

module.exports.impression = (req, res, next)->
  res.end script.pixel_tracker
  
  LIBS.models.Event.generate req, req.publisher, {
    type: "impression"
    ad_network: "double click"
  }


module.exports.script = (req, res, next)->
  if req.publisher.coverage_ratio <= Math.random() 
    return res.redirect script.roots.double_click.raw
 
  res.render "script", {
    publisher: req.publisher
    targets: script.targets
    root_script: script.roots.double_click.encoded
    random_slug: script.random_slug
  }, (error, code)->
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
      return proxy.modifier data, req.publisher
        
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
    LIBS.models.Event.generate req, req.publisher, {
      type: if data.media == "link" then "click" else "asset" 
      ad_network: "double click"
      asset_url: data.url
    }
