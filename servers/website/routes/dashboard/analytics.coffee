numeral = require "numeral"

module.exports.get_logs = (req, res, next)->
  req.publisher.getEvents({ 
    limit: 100 
    attributes: [ 
      "ip_address", "protected", "ad_network"
      "created_at", "type" 
    ]
    where: {
      type: {
        $ne: "asset" 
      }
    }
    order: [
      ['created_at', 'DESC'],
    ]
  }).then (events)->
    res.json(events)
    
  .catch next
  
  
module.exports.get_metrics = (req, res, next)->
  month_ago = new Date()
  month_ago.setUTCMonth month_ago.getUTCMonth() - 1
  month_ago.setUTCDate 1
  
  Promise.props({
    all: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
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
    protected: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
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
      impressions: numeral(props.impressions).format("0a")
      clicks: numeral(props.clicks).format("0a")
      assets: numeral(props.assets).format("0a")
      blocked: numeral(props.protected/(props.all or 1)).format("0[.]0%")
      ctr: numeral(props.all_clicks/(props.all_impressions or 1)).format("0[.]0%")
    }
    
  .catch next
