uglifyJS = require 'uglify-js'
randomstring = require "randomstring"
moment = require "moment"

module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")
    
  if not req.signedCookies.session?
    res.cookie "session", randomstring.generate(15), { 
      httpOnly: true 
      signed: true
      expires: moment().add("2", "year").toDate()
    }

  res.render "script/index.js", {
    enabled: req.publisher.config.coverage > Math.random() and req.miza_enabled
    random_slug: randomstring.generate(15)
    publisher: req.publisher
    page_url: req.get('referrer')
  }, (error, code)->
    if error?
      console.error error.stack
      code = ""
    
    req.miza_script = code
    
    if not CONFIG.disable.ads_server.minify
      req.miza_script = uglifyJS.minify(code, {
        fromString: true
      }).code
    
    next()
    
    
module.exports.script_send = (req, res, next)->
  res.send req.miza_script


module.exports.optout = (req, res, next)->
  res.cookie "optout", true, { 
    httpOnly: true
    signed: true 
    expires: moment().add("2", "month").toDate()
  }
  
  res.render "ad/optout"
  
  LIBS.ads.track req, {
    type: "optout"
    publisher: req.publisher
  }

 
module.exports.ad_frame = (req, res, next)->
  LIBS.exchanges.fetch(req).then (creative)->
    res.render "ad/frame", {
      publisher: req.publisher
      miza_script: req.miza_script
      creative: creative
      frame: req.query.frame
      is_protected: req.query.protected
    }
    
  .catch (error)->
    console.log error.stack or error
    res.render "ad/remove", {
      frame: req.query.frame
    }
    
  LIBS.ads.track req, {
    type: "request"
    publisher: req.publisher
  }
