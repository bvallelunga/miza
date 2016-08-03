request = require "request"

fetchRedis = (key)->
  new Promise (res, rej)->
    LIBS.redis.get key, (error, response)->                 
      if error? or not response?
        return res null
      
      try
        data = JSON.parse(response)
      catch error
        return res null
      
      data.cached = true
      
      if data.content.type == "Buffer"
        data.content = new Buffer(data.content.data)
      
      res data
      
      
download = (url, query, headers)->
  new Promise (res, rej)->
    request {
      method: "GET"
      encoding: null
      url: url
      followAllRedirects: true
      headers: {
        cookie: headers.cookie
      }
    }, (error, response, body)->
      if error? or response.statusCode != 200
        return rej error
      
      res response
      
  .then (response)->  
    data = {
      media: "asset"
      headers: response.headers or {}
      cached: false
    }
    
    if query.link?
      data.media = "link"
      data.href = response.request.uri.href
    
    else if data.headers['content-type'].indexOf("image") > -1
      data.media = "image"
      data.content = response.body
    
    else 
      data.content = response.body.toString("ascii")
      
    return data


module.exports = (path, query, headers)->
  fetchRedis(path.key).then (data)->  
    if data?
      return data
      
    return download path.url, query, headers

  .then (data)->
    return Object.assign path, data
