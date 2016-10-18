numeral = require "numeral"
  

module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    where: {
     is_demo: false
    }
    order: [
      ['name', 'ASC']
    ]
    include: [{
      model: LIBS.models.User
      as: "owner"
    }]
  }).then (publishers)->      
    res.render "admin/reports", {
      js: req.js.renderTags "admin-reports", "tooltip"
      css: req.css.renderTags "admin", "dashboard-analytics", "tooltip", "fa"
      title: "Admin Reporting"
      publishers: publishers
    }
    
  .catch next
  
  
module.exports.metrics = (req, res, next)->
  query = {
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
  }
  
  LIBS.models.Publisher.findAll({
    where: {
     is_demo: false
    }
  }).then (publishers)->    
    return Promise.map publishers, (publisher)->
      return publisher.reports(query, {
        paranoid: false
      }).then (report)->       
        report.totals.id = publisher.key
        return report.totals

  .then (reports)->     
    LIBS.models.PublisherReport.merge(reports).then (totals)-> 
      return {
        publishers: reports.map format_report
        totals: format_report totals
      }
  
  .then (reports)->
    res.json reports
    
  .catch next
  
  
format_report = (report)->
  report.active = report.pings_all > 0
  report.cpm = numeral(report.cpm).format("$0.00a")
  report.cpc = numeral(report.cpc).format("$0.00a")
  report.ctr = numeral(report.ctr).format("0[.]0%")
  report.owed = numeral(report.owed).format("$0[,]000[.]00a")
  report.impressions = numeral(report.impressions).format("0[.]0a")
  report.clicks = numeral(report.clicks).format("0a")
  report.protected = numeral(report.protected).format("0[.]0%")
  return report
  