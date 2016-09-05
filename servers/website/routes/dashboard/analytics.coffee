numeral = require "numeral"

module.exports.logs = (req, res, next)->
  req.publisher.getEvents({ 
    limit: 50 
    attributes: [ 
      "browser", "device", "network_name",
      "created_at", "type"
    ]
    where: {
      protected: true
      type: {
        $in: [
          "impression", "click"
        ]
      }
      created_at: {
        $gte: LIBS.helpers.past_date "month", req.query.date
      }
    }
    order: [
      ['created_at', 'DESC'],
    ]
  }).then (events)->
    res.json events.map (event)->
      return {
        network_name: event.network_name
        browser: event.browser.name or "Unknown"
        os: event.device.os.name or "Unknown"
        created_at: event.created_at
        type: event.type
      }
    
  .catch next
  
  
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
