numeral = require "numeral"
  

module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
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
  date_ago = LIBS.helpers.past_date req.query.range, req.query.date

  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
  }).then (publishers)->    
    return Promise.map publishers, (publisher)->
      return publisher.reports({
        created_at: {
          $gte: date_ago
        }
      }).then (report)->      
        report.id = publisher.key
        return report

  .then (reports)->  
    LIBS.models.Publisher.merge_reports(reports).then (totals)->      
      return {
        publishers: reports.map format_report
        totals: format_report totals
      }
  
  .then (reports)->
    res.json reports
    
  .catch next
  
  
format_report = (report)->
  report = report.toJSON()
  report.cpm = numeral(report.cpm).format("$0.00a")
  report.cpc = numeral(report.cpc).format("$0.00a")
  report.ctr = numeral(report.ctr).format("0[.]0%")
  report.fee = numeral(report.fee).format("0[.]0%")
  report.owed = numeral(report.owed).format("$0[,]000[.]00a")
  report.revenue = numeral(report.revenue).format("$0[,]000[.]00a")
  report.impressions = numeral(report.impressions).format("0[.]0a")
  report.clicks = numeral(report.clicks).format("0a")
  report.protected = numeral(report.protected).format("0[.]0%")
  return report
  