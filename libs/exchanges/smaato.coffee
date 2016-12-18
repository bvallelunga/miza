request = require "request"

module.exports = (headers, params)->
  new_headers = {}
  headers.host = "dev.miza.io"

  for header, value of headers
    new_headers["x-mh-X-#{header}"] = value
    
  params.apiver = "502"
  params.pub = "0"
  params.adspace = "0"
  params.divid = "smt-0"
  params.coppa = "1"
  
  if not params.format?
    params.format = "img"
  
  if not params.formatstrict?
    params.formatstrict = true
    
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