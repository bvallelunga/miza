request = require "request"
uglify = require "uglify-js"
script = require "./script"
proxy = require "./proxy"


module.exports.script = (req, res, next)->  
  res.render "script", {
    publisher: req.publisher,
    targets: script.targets,
    root_script: script.roots.double_click
  }, (error, code)->
    res.send uglify.minify(code, {
      fromString: true
    }).code
    

module.exports.proxy = (req, res, next)->
  proxy.path(req.get('host'), req.path).then (path)->
    return proxy.downloader path, req.query, req.headers
    
  .then (data)->  
    if data.media == "page" and not data.cached
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
    