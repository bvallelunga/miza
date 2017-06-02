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
  if req.query.demo != "true"
    res.cookie "optout", true, { 
      httpOnly: true
      signed: true 
      expires: moment().add(1, "day").toDate()
    }
  
  res.render "ad/optout"
  
  LIBS.ads.track req, {
    type: "optout"
    publisher: req.publisher
  }

 
module.exports.mobile_frame = (req, res, next)->
  LIBS.ads.track req, {
    type: "request"
    publisher: req.publisher
  }
  
  new Promise (respond, reject)->
    LIBS.exchanges.fetch(req, res).then (creative)->  
      format = creative.format.split(' ').join('')
      
      res.render "ad/frame/#{format}", {
        publisher: req.publisher
        miza_script: req.miza_script
        creative: creative
        frame: "frame"
        is_protected: false
        demo: req.query.demo == "true"
        width: Number req.query.width or 0
        height: Number req.query.height or 0
        mobile: true
      }, (error, code)->
        if error?
          return reject error
        
        respond code
        
  .then (code)->
    res.json {
      ad_available: true
      html: code
    }
    
    LIBS.ads.track req, {
      type: "delivery"
      publisher: req.publisher
    }
    
  .catch (error)->
    console.log error.stack or error
    
    res.json {
      ad_available: false
    }
    
    
module.exports.ad_frame = (req, res, next)->
  LIBS.ads.track req, {
    type: "request"
    publisher: req.publisher
  }
  
  LIBS.exchanges.fetch(req, res).then (creative)->  
    format = creative.format.split(' ').join('')
    
    res.render "ad/frame/#{format}", {
      publisher: req.publisher
      miza_script: req.miza_script
      creative: creative
      frame: req.query.frame or "frame"
      is_protected: req.query.protected
      demo: req.query.demo == "true"
      width: Number req.query.width or 0
      height: Number req.query.height or 0
      mobile: false
    }
    
    LIBS.ads.track req, {
      type: "delivery"
      publisher: req.publisher
    }
    
  .catch (error)->
    console.log error.stack or error
    res.render "ad/remove", {
      frame: req.query.frame
    }
  

module.exports.example_frame = (req, res, next)->
  LIBS.exchanges.fetch(req, res).then (creative)->  
    req.creative = creative
    next()
    
  .catch (error)->
    console.log error.stack or error
    res.render "ad/remove", {
      frame: req.query.frame
    }
  
  

module.exports.video_frame = (req, res, next)->
  LIBS.exchanges.video(req, res).then (creative)->    
    res.render "ad/video/#{creative.config.video}", {
      publisher: req.publisher
      creative: creative
      frame: req.query.frame
      is_protected: true
    }
    
  .catch (error)->
    console.log error.stack or error
    res.render "ad/remove", {
      frame: req.query.frame
    }
  


module.exports.demo_frame = (req, res, next)->
  creative = req.creative or LIBS.models.Creative.build({
    format: req.query.format
    link: req.query.link
    config: req.query.config
  })
  
  format = creative.format.split(' ').join('')
  res.render "ad/frame/#{format}", {
    publisher: req.publisher
    miza_script: req.miza_script
    creative: creative
    frame: req.query.frame
    is_protected: true
    demo: true
    mobile: false
    width: Number req.query.width or 0
    height: Number req.query.height or 0
  }
    

