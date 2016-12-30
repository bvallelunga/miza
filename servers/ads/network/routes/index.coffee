uglifyJS = require 'uglify-js'
randomstring = require "randomstring"
proxy = require "./proxy"

module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")
    
  if not req.cookies.session?
    res.cookie "session", randomstring.generate(15)

  res.render "script/index.js", {
    enabled: req.publisher.coverage_ratio > Math.random() and req.miza_enabled
    random_slug: randomstring.generate(15)
    publisher: req.publisher
  }, (error, code)->
    if error?
      console.error error.stack
      code = ""
    
    if CONFIG.is_dev
      req.miza_script = code
  
    else
      req.miza_script = uglifyJS.minify(code, {
        fromString: true
      }).code
    
    next()
    
    
module.exports.script_send = (req, res, next)->
  res.send req.miza_script
    
    
module.exports.ad_frame = (req, res, next)->      
  LIBS.exchanges.smaato({
    referer: req.get('referrer')
    "user-agent": req.get("user-agent")
  }, {
    ref: req.get('referrer')
    width: req.query.width
    height: req.query.height
    devip: req.ip or req.ips
    session: req.cookies.session
  }).then (payload)->
    res.render "ad/frame", {
      publisher: req.publisher
      miza_script: req.miza_script
      payload: payload
      frame: req.query.frame
    }
    
  .catch (error)->
    console.log error.stack or error
    res.render "ad/remove", {
      frame: req.query.frame
    }
      
      
module.exports.proxy = (req, res, next)->
  proxy.path(req.get('host'), req.path).then (path)->
    return proxy.downloader path, req.query, {
      referer: req.get('referrer')
      "user-agent": req.get("user-agent")
    }
    
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
