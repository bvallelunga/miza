request = require "request"
uglify = require "uglify-js"

# Cached Vars
root_script = new Buffer('www.googletagservices.com/tag/js/gpt.js').toString('base64')
targets = [
  "googlesyndication", "googleadservices",
  "doubleclick"
].map (target)->
  return "(#{target})"
.join "|"

module.exports.identifier = (req, res, next)->
  domains = req.host.split(".").slice(0, -1)
  
  if(domains.length > 0)
    req.sledge_id = domains[0]
  
  next()


module.exports.script = (req, res, next)->  
  res.render "sledge", {
    sledge_id: req.sledge_id,
    targets: targets,
    root_script: root_script
  }, (error, code)->
    res.send uglify.minify(code, {
      fromString: true
    }).code


module.exports.downloader = (req, res, next)->
  url = new Buffer(req.path.slice(1), 'base64').toString("ascii")
  
  if url.indexOf("://") == -1
    url = "http://" + url
  
  LIBS.redis.get url, (error, response)->     
    if not error? and response
      try
        req.data = JSON.parse(response)
        req.data.cached = true
        
        if req.data.content.type == "Buffer"
          req.data.content = new Buffer(req.data.content.data)
        
        return next()  
      
      catch e
        console.log e
    
    request {
      method: "GET"
      encoding: null
      url: url
      followAllRedirects: true
      headers: {
        cookie: req.headers.cookie
      }
    }, (error, response, body)->
      if error? or response.statusCode != 200
        res.status if response? then response.statusCode else 500
        return res.send error
      
      req.data = {
        url: url
        media: "page"
        headers: response.headers or {}
        cached: false
      }
      
      if req.query.link?
        req.data.media = "link"
        req.data.href = response.request.uri.href or url  
      
      else if req.data.headers['content-type'].indexOf("image") > -1
        req.data.media = "image"
        req.data.content = body
      
      else 
        req.data.content = body.toString("ascii")
      
      res.set req.data.headers
      next()


module.exports.modifier = (req, res, next)->  
  if req.data.media == "link"
    res.redirect req.data.href
    
  else if req.data.media == "image"
    res.end req.data.content, "binary"

  else
    if not req.data.cached
      replacers = [
        [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1#{req.sledge_id}$2"],
        [/div\-gpt\-ad/gi, req.sledge_id],
        [/google\_ads\_iframe/gi, "#{req.sledge_id}_iframe"],
        [/google\_/gi, "#{req.sledge_id}_"],
        [/img\_ad/gi, "#{req.sledge_id}_img"],
        [/google\-ad\-content-/gi, "#{req.sledge_id}-content"]
      ]
      
      for replacer in replacers
        req.data.content = req.data.content.replace replacer[0], replacer[1]

    res.send req.data.content
  
  if not req.data.cached
    LIBS.redis.set req.data.url, JSON.stringify(req.data)
