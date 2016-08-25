module.exports = (host, path)->  
  Promise.resolve().then ->
    encoded = url_safe_decoder path.slice(1).split(".")[0]
    url = new Buffer(encoded, 'base64').toString("ascii")
    key = "#{host}#{path}"
    
    if url.indexOf("://") == -1
      url = "http://" + url
    
    console.log url
    
    return {
      url: url
      key: key
    }
    

url_safe_decoder = (str)->
  str = (str + '===').slice(0, str.length + (str.length % 4));
  return str.replace(/-/g, '+').replace(/_/g, '/');
