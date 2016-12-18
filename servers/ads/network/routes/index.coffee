uglifyJS = require 'uglify-js'
randomstring = require "randomstring"

module.exports.script = (req, res, next)->
  if req.publisher.is_demo
    req.publisher.endpoint = req.get("host")

  res.render "script/index.js", {
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
      
      
module.exports.notfound = (req, res, next)->
  return res.end CONFIG.ads_server.denied.message