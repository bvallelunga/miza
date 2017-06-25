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
  
  # Width Check
  if Number(req.query.width or 0) > 500
    return Promise.reject LIBS.exchanges.errors.NO_AD_FOUND
  
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
      
  
  
module.exports.listing = (query, req, start=0, sponsored_only=true)->  
  lookup = geoip.lookup(req.ip_address)
  location = []
  country = null
   
  if lookup
    if lookup.city
      location.push lookup.city
      
    if lookup.region
      location.push lookup.region
      
    if lookup.country
      country = lookup.country.toLowerCase()
  
  if location.length > 0
    location = location.split(", ")
    
  else
    location = null
  
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
      userip: req.ip_address
      useragent: req.headers['user-agent']
      filter: 1
      l: location
      co: country
      q: (query or "").toLowerCase()
    }
  }).then (response)->
    if sponsored_only
      response.results = response.results.filter (job)->
        return job.sponsored
    
      if response.results.length == 0
        return LIBS.exchanges.indeed.listing(query, req, start, false)
        
    LIBS.ads.event.track req, {
      type: "indeed.search"
      extra: {
        feed: if sponsored_only then "sponsored" else "all" 
      }
    }
                
    return response
