var request = require("request")
var redis = require("redis").createClient()
var Promise = require("bluebird")
var uglify = require("uglify-js")

// Cached Vars
var root_script = new Buffer('www.googletagservices.com/tag/js/gpt.js').toString('base64')
var targets = [
  "googlesyndication", "googleadservices",
  "doubleclick"
].map(function(target) {
  return "(" + target + ")"
}).join("|")

module.exports.identifier = function(req, res, next) {
  var domains = req.host.split(".").slice(0, -1)
  
  if(domains.length > 0) {
    req.sledge_id = domains[0]
  }
  
  next()
}

module.exports.script = function(req, res, next) {
  if(!req.sledge_id || req.sledge_id == "sledge") 
    return res.redirect("/test.html")
  
  res.render("sledge", {
    sledge_id: req.sledge_id,
    targets: targets,
    root_script: root_script
  }, function(error, code) {
    res.send(uglify.minify(code, {
      fromString: true
    }).code)
  })
}

module.exports.downloader = function(req, res, next) {
  var url = new Buffer(req.path.slice(1), 'base64').toString("ascii")
  
  if(url.indexOf("://") == -1) {
    url = "http://" + url
  }
  
  redis.get(url, function(error, response) {       
    if(!error && response) {
      try {
        req.data = JSON.parse(response)
        
        if(req.data.content.type == "Buffer")
          req.data.content = new Buffer(req.data.content.data)
        
        return next()  
      } catch(e){ console.log(e) }
    }
    
    request({
      method: "GET",
      encoding: null,
      url: url,
      followAllRedirects: true,
      headers: {
        cookie: req.headers.cookie
      }
    }, function (error, response, body) { 
      if(error || response.statusCode != 200) {
        res.status(!!response ? response.statusCode : 500)
        return res.send(error) 
      }
      
      req.data = {
        media: "page",
        headers: response.headers || {}
      }
      
      if(!!req.query.link) {
        req.data.media = "link"
        req.data.href = response.request.uri.href || url
      }  
      
      if(req.data.headers['content-type'].indexOf("image") > -1) {
        req.data.media = "image"
        req.data.content = body
      } else {
        req.data.content = body.toString("ascii")
      }
      
      res.set(req.data.headers)
      redis.set(url, JSON.stringify(req.data))
      next()
    })
  })
}

module.exports.modifier = function(req, res, next) {  
  if(req.data.media == "link")
    return res.redirect(req.data.href)
    
  if(req.data.media == "image")
    return res.end(req.data.content, "binary")
  
  
  var data = req.data.content
  var replacers = [
    [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1" + req.sledge_id + "$2"],
    [/div\-gpt\-ad/gi, req.sledge_id],
    [/google\_ads\_iframe/gi, req.sledge_id + "_iframe"],
    [/google\_/gi, req.sledge_id + "_"],
    [/img\_ad/gi, req.sledge_id + "_img"],
    [/google\-ad\-content-/gi, req.sledge_id + "-content"]
  ]
  
  for (var i in replacers) {
    var replacer = replacers[i]
    
    data = data.replace(replacer[0], replacer[1])
  }

  res.send(data)
}