numeral = require "numeral"

module.exports.logs = (req, res, next)->
  redis_key = "#{req.publisher.key}.events"
      
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
  month_ago = LIBS.helpers.past_date "month", req.query.date
  from_date = LIBS.helpers.date_string month_ago
  to_date = LIBS.helpers.date_string new Date()
  where_query = 'properties["Protected"] == true and properties["Publisher ID"] == ' + req.publisher.id

  Promise.props({
    impressions: LIBS.mixpanel.export.segmentation({
      event: "ADS.EVENT.Impression"
      from_date: from_date
      to_date: to_date
      unit: "month"
      method: "numeric"
      where: where_query
    }).then(LIBS.mixpanel.export.sum_segments)
    clicks: LIBS.mixpanel.export.segmentation({
      event: "ADS.EVENT.Click"
      from_date: from_date
      to_date: to_date
      unit: "month"
      method: "numeric"
      where: where_query
    }).then(LIBS.mixpanel.export.sum_segments)
    all_pings: LIBS.mixpanel.export.segmentation({
      event: "ADS.EVENT.Ping"
      from_date: from_date
      to_date: to_date
      unit: "month"
      method: "numeric"
      where: 'properties["Publisher ID"] == ' + req.publisher.id
    }).then(LIBS.mixpanel.export.sum_segments)
    protected_pings: LIBS.mixpanel.export.segmentation({
      event: "ADS.EVENT.Ping"
      from_date: from_date
      to_date: to_date
      unit: "month"
      method: "numeric"
      where: where_query
    }).then(LIBS.mixpanel.export.sum_segments)
  }).then (props)->  
    res.json {
      impressions: numeral(props.impressions).format("0[.]0a")
      clicks: numeral(props.clicks).format("0a")
      views: numeral(props.all_pings).format("0[.]0a")
      blocked: numeral(props.protected_pings/(props.all_pings or 1)).format("0[.]0%")
      ctr: numeral(props.clicks/(props.impressions or 1)).format("0[.]0%")
    }
    
  .catch next
