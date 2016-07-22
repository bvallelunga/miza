var request = require("request")
var redis = require("redis").createClient()
var Promise = require("bluebird")


module.exports.downloader = function(req, res, next) {
  var url = new Buffer(req.path.slice(1), 'base64').toString("ascii")
  
  console.log(url)
  
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
    [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1" + req.query.id + "$2"],
    [/div\-gpt\-ad/gi, req.query.id],
    [/google\_ads\_iframe/gi, req.query.id + "_iframe"],
    [/google\_/gi, req.query.id + "_"],
    [/img\_ad/gi, req.query.id + "_img"]
  ]
  
  for (var i in replacers) {
    var replacer = replacers[i]
    
    data = data.replace(replacer[0], replacer[1])
  }

  res.send(data)
}