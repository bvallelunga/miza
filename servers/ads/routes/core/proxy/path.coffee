module.exports = (host, path)->  
  Promise.resolve().then ->
    url = new Buffer(path.slice(1), 'base64').toString("ascii")
    key = "#{host}#{path}"
    
    if url.indexOf("://") == -1
      url = "http://" + url
      
    return {
      url: url
      key: key
    }