module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).then (publishers)->  
    res.render "admin/reports", {
      js: req.js.renderTags "admin-reports"
      css: req.css.renderTags "admin", "dashboard-analytics", "fa"
      title: "Admin Reporting"
      publishers: publishers
    }


module.exports.metrics = (req, res, next)->
  LIBS.models.Event.count({
    where: {
      protected: true
      type: "impression"
      paid_at: null
    }
  }).then (impressions)-> 
    industry = req.publisher.industry
    next_month = new Date()
    next_month.setUTCMonth next_month.getUTCMonth() + 1
    next_month.setUTCDate 1
   
    res.json {
      billed: next_month
      cpm: numeral(industry.cpm).format("$0.00a")
      owe: numeral(LIBS.models.Publisher.revenue(impressions, industry)).format("$0[,]000[.]00a")
      fee: numeral(industry.fee).format("0[.]0%")
      revenue: numeral(LIBS.models.Publisher.owed(impressions, industry)).format("$0[,]000.00a")
    }
  
  
module.exports.publisher_metrics = (req, res, next)->
  console.log req.publisher
  res.json {}