request = require "request-promise"
geoip = require 'geoip-lite'

module.exports = (req, res)-> 
#   start = req.signedCookies.indeed or 0
#   
#   if start > 10
#     start = 0
#   
#   LIBS.exchanges.indeed.listing(
#     "", req, start
#   ).then (data)->   
#   res.cookie "indeed", ++start, { 
#     httpOnly: true
#     signed: true 
#     maxAge: 24 * 60 * 60 # 1 day
#   }
  
  creative = LIBS.models.Creative.build({
    format: "indeed"
    config: {
      results: []
      search: ""
    }
    trackers: [
      "http://gdc.indeed.com/rpc/apilog?a=apiresults"
    ]
  })
  
  creative.id = "indeed"
  creative.campaign_id = "indeed"
  creative.advertiser_id = "indeed"
  return Promise.resolve creative
      
  
  
module.exports.listing = (query, req, start=0)->
  ip = req.headers["CF-Connecting-IP"] or req.ip or req.ips
  lookup = geoip.lookup(ip)
  location = ""
  country = ""
   
  if lookup
    location = "#{lookup.city}, #{lookup.region}"
    country = (lookup.country or "").toLowerCase()
  
  request({
    url: "http://api.indeed.com/ads/apisearch"
    json: true
    qs: {
      publisher: CONFIG.indeed.publisher
      format: "json"
      v: 2
      limit: 20
      start: start
      chnl: req.publisher.key
      userip: ip
      useragent: req.headers['user-agent']
      filter: 1
      l: location
      co: country
      q: (query or "").toLowerCase()
    }
  })
