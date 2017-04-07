request = require "request"

download = (url, query, headers)->
  new Promise (res, rej)->  
    request {
      method: "GET"
      encoding: null
      url: url
      followAllRedirects: true
      headers: headers
    }, (error, response, body)->
      if error?
        return rej error
      
      res response
      
  .then (response)->      
    data = {
      media: "asset"
      headers: response.headers or {}
      url: url
    }
    
    data.content_type = data.headers['content-type'] or ""
    
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
  download(path.url, query, headers).then (data)->
    return Object.assign path, data

