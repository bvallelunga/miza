request = require "request-promise"
geoip = require 'geoip-lite'

module.exports = (req, res)-> 
  start = req.signedCookies.indeed or 0
  
  if start > 10
    start = 0
   
  req.publisher.getIndustry().then (industry)->  
    LIBS.exchanges.indeed.listing(
      industry.name, req, start
    ).then (data)->   
      res.cookie "indeed", ++start, { 
        httpOnly: true
        signed: true 
        maxAge: 24 * 60 * 60 # 1 day
      }
      
      return LIBS.models.Creative.build({
        format: "indeed"
        config: {
          results: data.results
          search: industry.name.toLowerCase()
        }
        trackers: [
          "http://gdc.indeed.com/rpc/apilog?a=apiresults"
        ]
      })
      
  
  
module.exports.listing = (query, req, start=0)->
  ip = req.headers["CF-Connecting-IP"] or req.ip or req.ips
  lookup = geoip.lookup(ip)
  location = ""
  country = ""
  
  if lookup
    location = "#{lookup.city}, #{lookup.region}"
    country = lookup.country.toLowerCase()
  
  request({
    url: "http://api.indeed.com/ads/apisearch"
    json: true
    qs: {
      publisher: CONFIG.indeed.publisher
      format: "json"
      v: 2
      limit: 5
      start: start
      chnl: req.publisher.key
      userip: ip
      useragent: req.headers['user-agent']
      filter: 1
      l: location
      co: country
      q: query.toLowerCase()
    }
  })
