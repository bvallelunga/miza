request = require "request-promise"

module.exports = (req, res)->  
  start = req.signedCookies.indeed or 0
  
  if start > 10
    start = 0

  req.publisher.getIndustry().then (industry)->  
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
        userip: "70.197.12.195" or req.headers["CF-Connecting-IP"] or req.ip or req.ips
        useragent: req.headers['user-agent']
        filter: 1
        q: industry.name.toLowerCase()
      }
    }).then (data)->    
      if data.results.length == 0
        return Promise.reject LIBS.exchanges.errors.NO_AD_FOUND
        
      res.cookie "indeed", ++start, { 
        httpOnly: true
        signed: true 
        maxAge: 24 * 60 * 60 # 1 day
      }
      
      return LIBS.models.Creative.build({
        format: "indeed"
        config: {
          results: data.results
        }
      })
      
  