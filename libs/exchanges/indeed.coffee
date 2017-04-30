request = require "request-promise"

module.exports = (req)->  
  request({
    url: "http://api.indeed.com/ads/apisearch"
    qs: {
      publisher: CONFIG.indeed.publisher
      format: "json"
      v: 2
      limit: 5
      chnl: req.publisher.key
      userip: "70.197.12.195" or req.headers["CF-Connecting-IP"] or req.ip or req.ips
      useragent: req.headers['user-agent']
      filter: 1
    }
  }).then (data)->
    console.log data
    
    return Promise.reject LIBS.exchanges.errors.NO_AD_FOUND