request = require "request"
jsdom = require "jsdom"
wait = require "wait"
jQuery = ""

request "http://code.jquery.com/jquery.js", (error, response, body)->
  jQuery = body


module.exports = (headers, params)->
  
  fetch_content(headers, params).then (response)->  
    if response.type != "RICHMEDIA"
      return response
      
    parse_content(response.mediadata).then (payload)->
      payload.beacons = payload.beacons.concat(response.beacons)
      payload.width = response.width
      payload.height = response.height
      
      if not payload.link
        return Promise.reject "Miza: Could not parse ad"

      return payload
  
  .then convert_image
        

convert_image = (payload)->
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
  

parse_content = (html)->
  new Promise (res, rej)->
    download_list = []
    
    wait.waitUntil (-> jQuery.length > 0), 10, ->  
      jsdom.env """
        <div id="smt-0">#{html}</div>
      """, {
        src: [ jQuery ]
        userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
        resourceLoader: (resource, callback)->               
          download_list.push resource        
          resource.defaultFetch (error, content)->
            download_list.shift()
            callback error, content
        
        features: {
          FetchExternalResources: ["script", "frame", "iframe"]
          ProcessExternalResources: ["script"]
        }
      }, (error, window)->
        if error? then return rej error 
        
        wait.wait 100, ->
          wait.waitUntil (-> download_list.length == 0), 200, ->        
            collect_content(window.$).then (response)->
              res response
              window.close()
            
            .catch (error)->
              rej error
              window.close() 


collect_content = ($, data)->
  data = data or {
    target: null
    link: null
    beacons: []
    html: $("body").html()
  }

  Promise.resolve().then ->
    # Find Link & Target
    $image = ($("a img, img").filter ->
      $this = $(this)
      width = parseInt $this.width() or this.width
      height = parseInt $this.height() or this.height
      return width > 20 and height > 20  
      
    .eq(0))
    
    data.link = $image.attr("src")
    data.target = $image.parents("a").attr("href")
        
    # Find Beacons
    data.beacons = ($("img").filter ->
      $this = $(this)
      width = parseInt $this.width() or this.width
      height = parseInt $this.height() or this.height
      return width < 5 and height < 5
    
    .map ->
      return this.src
      
    .get())
     
    # Find iFrames
    if not data.link?
      iframes = ($("iframe").filter ->
        $this = $(this)
        width = parseInt $this.width() or this.width
        height = parseInt $this.height() or this.height
        return width > 20 and height > 20  
      
      .map ->
        return $(this).contents().find("html").html()
        
      .get())
      
      if iframes.length > 0
        $("html").html iframes[0]
        return collect_content $, data
     
    return data
    

fetch_content = (headers, params)->
  new_headers = {}

  for header, value of headers
    new_headers["x-mh-X-#{header}"] = value
    
  params.apiver = "502"
  params.pub = CONFIG.exchanges.smaato.publisher
  params.adspace = CONFIG.exchanges.smaato.adspace
  params.divid = "smt-#{CONFIG.exchanges.smaato.adspace}"
  params.dimensionstrict = false
  
  if not params.format?
    params.format = "richmedia"
  
  if not params.formatstrict?
    params.formatstrict = false
    
  if not params.response? 
    params.response = "json"

  new Promise (res, rej)->  
    request {
      method: "GET"
      url: "http://soma.smaato.net/oapi/reqAd.jsp"
      followAllRedirects: true
      qs: params
      headers: new_headers
      json: params.response == "json"
    }, (error, response, body)->    
      if error? or response.statusCode != 200
        return rej error
        
      if body.status == "ERROR"
        return rej body.errormessage
      
      res body
