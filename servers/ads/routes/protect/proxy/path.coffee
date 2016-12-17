is_url_test = /\/\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/

module.exports = (host, path, url)->  
  Promise.resolve().then ->    
    if not is_url_test.test(url)
      return Promise.reject "Invalid url"
    
    return {
      url: url
      key: "ads_server.cache.#{host}#{path}"
    }
