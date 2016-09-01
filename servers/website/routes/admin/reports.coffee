numeral = require "numeral"


date_creator = (range)->
  range_at = new Date()
  
  if range == "month"
    range_at.setUTCMonth range_at.getUTCMonth() - 1
    range_at.setUTCDate 1
    
  else if range == "week"
    range_at = get_monday range_at
    
  else # day
    range_at.setUTCHours 0, 0, 0, 0
    
  return range_at


get_monday = (date)->
  d = new Date date
  day = d.getDay()
  diff = d.getDate() - day + (day == 0 ? -6:1)
  return new Date(d.setDate(diff))
  

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
    next_month = new Date()
    next_month.setUTCMonth next_month.getUTCMonth() + 1
    next_month.setUTCDate 1
  
    res.render "admin/reports", {
      js: req.js.renderTags "admin-reports"
      css: req.css.renderTags "admin", "dashboard-analytics"
      title: "Admin Reporting"
      publishers: publishers
      next_month: next_month
    }


module.exports.metrics = (req, res, next)->
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
        impressions: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            protected: true
            type: "impression"
            paid_at: null
            created_at: {
              $gte: date_creator req.query.range
            }
          }
        })
        clicks: LIBS.models.Event.count({
          where: {
            publisher_id: publisher.id
            protected: true
            type: "click"
            paid_at: null
            created_at: {
              $gte: date_creator req.query.range
            }
          }
        })
      }).then (props)->
        return {
          clicks: props.clicks
          impressions: props.impressions
          owe: LIBS.models.Publisher.owed(props.impressions, publisher.industry)
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
  LIBS.models.Event.count({
    where: {
      publisher_id: req.publisher.id
      protected: true
      type: "impression"
      paid_at: null
      created_at: {
        $gte: date_creator req.query.range
      }
    }
  }).then (impressions)-> 
    industry = req.publisher.industry
    owe_raw = LIBS.models.Publisher.owed(impressions, industry)
    revenue_raw = LIBS.models.Publisher.revenue(impressions, industry)
   
    res.json {
      owe_raw: owe_raw
      owe: numeral(owe_raw).format("$0[,]000[.]00a")
      revenue_raw: revenue_raw
      revenue: numeral(revenue_raw).format("$0[,]000.00a")
    }
    
  .catch next
