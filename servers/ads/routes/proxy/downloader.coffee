request = require "request"

fetchRedis = (path)->
  new Promise (res, rej)-> 
    if CONFIG.disable.ads_server.downloader
      return res null
      
    if path.url.indexOf(".json") > -1
      return res null
   
    LIBS.redis.get path.key, (error, response)->                 
      if error? or not response?
        return res null
      
      try
        data = JSON.parse response
      catch error
        return res null
      
      if data.content? and data.content.type == "Buffer"
        data.content = new Buffer(data.content.data)
      
      data.cached = true
      data.to_cache = false
      res data
      
      
download = (url, query, headers)->
  new Promise (res, rej)->  
    request {
      method: "GET"
      encoding: null
      url: url
      followAllRedirects: true
      headers: headers
    }, (error, response, body)->
      if error? or response.statusCode != 200
        return rej error
      
      res response
      
  .then (response)->      
    data = {
      media: "asset"
      headers: response.headers or {}
      cached: false
      to_cache: url.indexOf(".json") == -1 and url.indexOf("callback=") == -1
      url: url
    }
    
    data.content_type = data.headers['content-type'] or "text"
    
    if query.link?
      data.media = "link"
      data.href = response.request.uri.href
    
    else if data.content_type.indexOf("text") == -1 and data.content_type.indexOf("javascript") == -1
      data.media = "binary"
      data.content = response.body
    
    else 
      data.content = response.body.toString("ascii")
      
    return data


module.exports = (path, query, headers)->
  Promise.resolve().then ->
    if query.link?
      return null
      
    return fetchRedis(path)
  
  .then (data)->  
    if data?
      return data
      
    return download path.url, query, headers

  .then (data)->
    return Object.assign path, data

