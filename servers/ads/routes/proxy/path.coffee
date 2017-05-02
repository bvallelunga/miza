is_url_test = /\/\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/
URL = require "url"

module.exports = (host, path, req)->  
  Promise.resolve().then ->
    encoded = url_safe_decoder path.slice(1).split(".")[0]
    url = new Buffer(encoded, 'base64').toString("ascii")
    key = "ads_server.cache.#{host}#{path}"
    
    if url.slice(0, 2) == "//"
      url = "http:" + url
      
    else if path[0] == "/" and req.get("referrer")?
      referrer_url = URL.parse(req.get("referrer")).pathname.slice(1).split(".")[0]
      referrer_original = new Buffer(referrer_url, 'base64').toString("utf8")
      referrer = URL.parse(referrer_original)
      referrer_original_split = referrer.pathname.split("/")      
      path = path.split("/").map (substring, i)->
        if substring.indexOf("aHR0") > -1
          substring = referrer_original_split[i]
        
        return substring
      .join("/")
      url = "http://#{referrer.hostname}#{path}"
      
    else if url.indexOf("://") == -1
      url = "http://" + url
    
    return {
      url: url
      key: key
    }
    

module.exports.decoder = url_safe_decoder = (str)->
  str = (str + '===').slice(0, str.length + (str.length % 4))
  return str.replace(/-/g, '+').replace(/_/g, '/')