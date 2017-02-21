uglifyJS = require 'uglify-js'
proxy = require "./proxy"
randomstring = require "randomstring"

  
module.exports.abtest = (req, res, next)->
  abtest = req.publisher.config.abtest.coverage
  alt_publisher = req.publisher.config.abtest.alt_publisher
  protocol = req.headers["HTTP_X_FORWARDED_PROTO"] or req.protocol
  
  if req.get("referrer").slice(0,5) == "https"
    protocol = "https"
  
  if abtest > Math.random()
    return next()
    
  LIBS.models.Publisher.findById(alt_publisher).then (publisher)->
    endpoint = publisher.endpoint
    
    if publisher.is_demo
      endpoint = "#{publisher.key}.#{CONFIG.web_server.domain}"
    
    res.redirect "#{protocol}://#{endpoint}"
    
  .catch next


module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")

  res.render "carbon/script", {
    enabled: req.publisher.config.coverage > Math.random() and req.miza_enabled
    random_slug: randomstring.generate(15)
    publisher: req.publisher
    network: LIBS.models.defaults.carbon_network
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
    return proxy.downloader path, req.query, {
      referer: req.get('referrer')
      "user-agent": req.get("user-agent")
    }
    
  .then (data)->   
    if data.media == "asset" and not data.cached
      return proxy.modifier data, req.publisher
        
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
    
    LIBS.ads.track req, {
      type: if data.media == "link" then "click" else "asset"
      asset_url: data.href
      publisher: req.publisher
    }
      
  
  .catch next
      