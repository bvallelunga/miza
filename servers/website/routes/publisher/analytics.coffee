numeral = require "numeral"

module.exports.logs = (req, res, next)->
  redis_key = "publisher.#{req.publisher.key}.events"
      
  LIBS.redis.get redis_key, (error, response)->
    if error?
      return next error
      
    try
      events = JSON.parse(response) or []
    catch error
      events = []
    
    res.json events.sort (a, b)->
      a_date = new Date a.created_at
      b_date = new Date b.created_at
      return b_date - a_date
  
  
module.exports.metrics = (req, res, next)->  
  req.publisher.reports({
    created_at: {
      $gte: new Date req.query.start_date
      $lte: new Date req.query.end_date
    }
    $or: [
      {
        interval: "hour"
      }
      {
        interval: "minute"
        deleted_at: null
      }
    ]
  }, {
    paranoid: false
  }).then (reports)->
    totals = reports.totals
    
    res.json {
      impressions: numeral(totals.impressions).format("0[.]0a")
      clicks: numeral(totals.clicks).format("0a")
      views: numeral(totals.pings_all).format("0[.]0a")
      blocked: numeral(totals.protected).format("0[.]0%")
      ctr: numeral(totals.ctr).format("0[.]0%")
    }
    
  .catch next
