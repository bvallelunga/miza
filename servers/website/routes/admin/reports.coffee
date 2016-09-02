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
      next_month: LIBS.helpers.past_date "month+1"
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
    }
    
    for publisher in publishers
      totals.clicks += publisher.clicks
      totals.impressions += publisher.impressions
      totals.owe += publisher.owe
      totals.revenue += publisher.revenue
      
    return res.json {
      owe: numeral(totals.owe).format("$0[,]000[.]00a")
      revenue: numeral(totals.revenue).format("$0[,]000.00a")
      impressions: numeral(totals.impressions).format("0[.]00a")
      clicks: numeral(totals.clicks).format("0[.]00a")
    }
    
  .catch next
  
  
module.exports.publisher_metrics = (req, res, next)->
  Promise.props({
    owed_impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "impression"
        paid_at: null
      }
    })
    impressions: LIBS.models.Event.count({
      where: {
        publisher_id: req.publisher.id
        protected: true
        type: "impression"
        created_at: {
          $gte: LIBS.helpers.past_date req.query.range, req.query.date
        }
      }
    })
  }).then (props)-> 
    industry = req.publisher.industry
    owe_raw = LIBS.models.Publisher.owed(props.owed_impressions, industry)
    revenue_raw = LIBS.models.Publisher.revenue(props.impressions, industry)
   
    res.json {
      owe_raw: owe_raw
      owe: numeral(owe_raw).format("$0[,]000[.]00a")
      revenue_raw: revenue_raw
      revenue: numeral(revenue_raw).format("$0[,]000.00a")
    }
    
  .catch next
