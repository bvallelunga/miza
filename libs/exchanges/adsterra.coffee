request = require "request"
jsdom = require "jsdom"
wait = require "wait"
url_parser = require('url').parse
jQuery = ""

request "http://code.jquery.com/jquery.js", (error, response, body)->
  jQuery = body


module.exports = ->
  fetch_content().then (payload)->    
    if not payload.link
      return Promise.reject "Miza: Could not parse ad"

    return payload
  
  .then (payload)->
    new Promise (res, rej)->  
      request {
        method: "GET"
        encoding: null
        url: payload.link
        followAllRedirects: true
      }, (error, response, body)->
        if error? then return rej error
        
        payload.link = "data:" + response.headers["content-type"] + ";base64," + new Buffer(body).toString('base64')
        res payload
  

fetch_content = ->
  new Promise (res, rej)->
    download_list = []
    
    wait.waitUntil (-> jQuery.length > 0), 10, ->  
      jsdom.env """
        <div>
          <script type='text/javascript' src='//pl13436752.puserving.com/46/83/86/46838626a2ee3c0dbcf3273979686ae8.js'></script>
        </div>
      """, {
        src: [ jQuery ]
        referrer: "http://sitesforprofit.com"
        userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
        resourceLoader: (resource, callback)->  
          url = url_format resource.url.href
          download_list.push resource  
          
          request url, (error, response, content)->
            download_list.shift()
            callback error, content
        
        features: {
          FetchExternalResources: ["script"]
          ProcessExternalResources: ["script"]
          SkipExternalResources: false
        }
      }, (error, window)->
        if error? then return rej error 
        
        wait.wait 100, ->
          wait.waitUntil (-> download_list.length == 0), 50, ->        
            collect_content(window.$).then (response)->
              res response
              window.close()
            
            .catch (error)->
              rej error
              window.close() 


collect_content = ($)->
  data = {
    target: null
    link: null
    beacons: []
    html: $("html").html()
  }

  return data
    
    
url_format = (url)->
  if not url? then return url
  
  if not url_parser(url).protocol
    url = "http:#{url}"
    
  return url
    