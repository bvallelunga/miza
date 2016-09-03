numeral = require "numeral"
  

module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
    order: [
      ['name', 'ASC']
    ]
  }).then (publishers)->      
    res.render "admin/reports", {
      js: req.js.renderTags "admin-reports"
      css: req.css.renderTags "admin", "dashboard-analytics"
      title: "Admin Reporting"
      publishers: publishers
    }
    
  .catch next


module.exports.metrics = (req, res, next)->
  date = LIBS.helpers.past_date req.query.range, req.query.date

  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).then (publishers)->
    Promise.all publishers.map (publisher)->
      Promise.props({
        all_pings: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            type: "ping"
            created_at: {
              $gte: date
            }
          }
        })
        protected_pings: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            type: "ping"
            protected: true
            created_at: {
              $gte: date
            }
          }
        })
        owed_impressions: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            protected: true
            type: "impression"
            paid_at: null
          }
        })
        impressions: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            protected: true
            type: "impression"
            created_at: {
              $gte: date
            }
          }
        })
        clicks: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            protected: true
            type: "click"
            created_at: {
              $gte: date
            }
          }
        })
      }).then (props)->
        return {
          key: publisher.key
          all_pings: props.all_pings
          protected_pings: props.protected_pings
          clicks: props.clicks
          impressions: props.impressions
          owe: LIBS.models.Publisher.owed(props.owed_impressions, publisher.industry)
          revenue: LIBS.models.Publisher.revenue(props.impressions, publisher.industry)
        }
  
  .then (publishers)->
    totals = {
      clicks: 0
      impressions: 0
      owe: 0
      revenue: 0
      protected_pings: 0
      all_pings: 0
    }
    
    for publisher in publishers    
      totals.clicks += publisher.clicks
      totals.impressions += publisher.impressions
      totals.owe += publisher.owe
      totals.revenue += publisher.revenue
      totals.all_pings += publisher.all_pings
      totals.protected_pings += publisher.protected_pings
      
      publisher.protected = numeral(publisher.protected_pings/(publisher.all_pings or 1)).format("0%")
      publisher.owe = numeral(publisher.owe).format("$0[,]000a")
      publisher.revenue = numeral(publisher.revenue).format("$0[,]000a")
      
    return res.json {
      totals: {
        owe: numeral(totals.owe).format("$0[,]000[.]00a")
        revenue: numeral(totals.revenue).format("$0[,]000.00a")
        impressions: numeral(totals.impressions).format("0[.]0a")
        clicks: numeral(totals.clicks).format("0[.]0a")
        protected: numeral(totals.protected_pings/(totals.all_pings or 1)).format("0%")
      }
      publishers: publishers
    }
    
  .catch next
  
