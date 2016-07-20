var request = require("request")

module.exports.downloader = function(req, res, next) {
  var url = Buffer.from(req.path.slice(1), "base64").toString("ascii")
  
  if(url.indexOf("://") == -1) {
    url = "http://" + url
  }
  
  console.log(url)
  request.get(url, function (error, response, body) {
    if(error || response.statusCode != 200) {
      res.status(!!response ? response.statusCode : 500)
      return res.send(error) 
    }
    
    req.data = body
    next()
  })
}

module.exports.modifier = function(req, res, next) {
  var data = req.data
  var replacers = [
    [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1" + req.query.id + "$2"],
    [/div\-gpt\-ad/gi, req.query.id],
    [/google\_ads\_iframe/gi, req.query.id + "_iframe"],
    [/google_/gi, req.query.id + "_"],
    [/img_ad/gi, req.query.id]
  ]
  
  for (var i in replacers) {
    var replacer = replacers[i]
    data = data.replace(replacer[0], replacer[1])
  }

  res.send(data)
}