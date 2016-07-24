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
  
  if(!!req.query.link) {
    return res.redirect(url)
  }
  
  redis.get(url, function(error, response) {    
    if(!!response) {
      try {
        req.data = JSON.parse(response)
        return next()  
      } catch(e){ }
    }
    
    request({
      method: "GET",
      encoding: null,
      url: url,
      followAllRedirects: true
    }, function (error, response, body) {
      if(error || response.statusCode != 200) {
        res.status(!!response ? response.statusCode : 500)
        return res.send(error) 
      }
      
      req.data = {
        type: response.headers['content-type']
      }
      
      if(req.data.type.indexOf("image") > -1) {
        res.setHeader("content-type", req.data.type)
        return res.end(body, "binary")
      }
      
      req.data.content = body.toString("ascii")
      redis.set(url, JSON.stringify(req.data))
      
      next()
    })
  })
}

module.exports.modifier = function(req, res, next) {
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