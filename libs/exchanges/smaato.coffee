request = require "request"
jsdom = require "jsdom"
jQuery = require "jquery"
wait = require "wait"


module.exports = (headers, params)->
  
  fetch_content(headers, params).then (response)->
    if response.type != "RICHMEDIA"
      return response
      
    parse_content(response.mediadata).then (payload)->
      payload.beacons = payload.beacons.concat(response.beacons)
      payload.width = response.width
      payload.height = response.height
      
      if not payload.link
        return Promise.reject "No ad available"
      
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
  

parse_content = (html)->
  new Promise (res, rej)->
    download_list = []
  
    jsdom.env """
      <div id="smt-0">#{html}</div>
    """, {
      userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
      resourceLoader: (resource, callback)->
        console.log resource.url.href                
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
      
      wait.wait 500, ->
        wait.waitUntil (-> download_list.length == 0), 500, ->        
          $ = jQuery(window)
          
          collect_content($).then (response)->
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
    html: $("body").html()
  }

  Promise.resolve().then ->
    # Find Link & Target
    data.target = $("a").attr("href")
    data.link = $("a img").attr("src")
    
    # Find Beacons
    data.beacons = ($("img").filter ->
      return this.width < 5 and this.height < 5
    
    .map ->
      return this.src
      
    .get())
     
    return data
    

fetch_content = (headers, params)->
  new_headers = {}
  headers.host = "dev.miza.io"

  for header, value of headers
    new_headers["x-mh-X-#{header}"] = value
    
  params.apiver = "502"
  params.pub = "0"
  params.adspace = "0"
  params.divid = "smt-0"
  params.dimensionstrict = true
  
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
