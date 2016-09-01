numeral = require "numeral"

module.exports.logs = (req, res, next)->
  req.publisher.getEvents({ 
    limit: 100 
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
        $gte: LIBS.helpers.past_date "month"
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
  month_ago = LIBS.helpers.past_date "month"
  
  Promise.props({
    all_pings: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        type: "ping"
        created_at: {
          $gte: month_ago
        }
      }
    })
    all_clicks: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        type: "click"
        created_at: {
          $gte: month_ago
        }
      }
    })
    all_impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        type: "impression"
        created_at: {
          $gte: month_ago
        }
      }
    })
    protected_pings: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        type: "ping"
        protected: true
        created_at: {
          $gte: month_ago
        }
      }
    })
    impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "impression"
        created_at: {
          $gte: month_ago
        }
      }
    })
    clicks: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "click"
        created_at: {
          $gte: month_ago
        }
      }
    })
    assets: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "asset"
        created_at: {
          $gte: month_ago
        }
      }
    })
  }).then (props)->  
    res.json {
      impressions: numeral(props.impressions).format("0[.]00a")
      clicks: numeral(props.clicks).format("0[.]00a")
      assets: numeral(props.assets).format("0[.]00a")
      blocked: numeral(props.protected_pings/(props.all_pings or 1)).format("0[.]0%")
      ctr: numeral(props.all_clicks/(props.all_impressions or 1)).format("0[.]0%")
    }
    
  .catch next
