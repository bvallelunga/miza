request = require "request"
jsdom = require "jsdom"
wait = require "wait"
url_parser = require('url').parse
jQuery = ""
carbon_ads = {}

request "http://code.jquery.com/jquery.js", (error, response, body)->
  jQuery = body


module.exports = ->
  CARBON_CONFIG = CONFIG.exchanges.carbon

  Promise.resolve().then ->
    carbon_keys = Object.keys(carbon_ads)
    
    if Math.random() < CARBON_CONFIG.use_cache and carbon_keys.length >= CARBON_CONFIG.min_ads_cache
      LIBS.queue.publish "carbon-mimic", {}
      return carbon_ads[carbon_keys[Math.floor(Math.random() * carbon_keys.length)]]

    fetch_content().then (payload)->
      if not payload.link
        return Promise.reject "Miza: Could not parse ad"
        
      new Promise (res, rej)->
        request {
          method: "GET"
          encoding: null
          url: payload.link
          followAllRedirects: true
        }, (error, response, body)->
          if error? then return rej error
          
          key = payload.link
          payload.link = "data:" + response.headers["content-type"] + ";base64," + new Buffer(body).toString('base64')
          carbon_ads[key] = payload
          res payload


module.exports.fetch_content = fetch_content = ->
  new Promise (res, rej)->
    download_list = []
    
    wait.waitUntil (-> jQuery.length > 0), 10, ->  
      jsdom.env """
        <div>
          <script type="text/javascript" src="http://cdn.carbonads.com/carbon.js?zoneid=1673&serve=C6AILKT&placement=exisweb" id="_carbonads_js"></script>
        </div>
      """, {
        src: [ jQuery ]
        referrer: "http://exisweb.net"
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

  Promise.resolve().then ->
    # Find Link & Target
    $image = ($("a img, img").filter ->
      $this = $(this)
      width = parseInt $this.width() or this.width
      height = parseInt $this.height() or this.height
      return width > 20 and height > 20  
      
    .eq(0))
    
    data.width = $image.get(0).width * 1.5
    data.height = $image.get(0).height * 1.5
    data.link = url_format $image.attr("src")
    data.target = url_format $image.parents("a").attr("href")
    data.text = $image.parents("a").next("a").text()
        
    # Find Beacons
    data.beacons = ($("img").filter ->
      $this = $(this)
      width = parseInt $this.width() or this.width
      height = parseInt $this.height() or this.height
      return width < 5 and height < 5
    
    .map ->
      return url_format this.src
      
    .get())
     
    return data
    
    
url_format = (url)->
  if not url? then return url
  
  if not url_parser(url).protocol
    url = "http:#{url}"
    
  return url
    