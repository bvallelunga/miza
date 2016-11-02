moment = require "moment"

module.exports = (interval)->
  interval = interval or "day"
  levels = {
    day: ["hour", 12]
    hour: ["minute", 30]
  }

  return require("../template") (job)->     
    if Object.keys(levels).indexOf(interval) == -1
      return Promise.reject "Invalid interval"
      
    end_date = moment().subtract(1, interval)
            .endOf(interval)
            .subtract(levels[interval][1], levels[interval][0])
            .toDate()  
    
    LIBS.models.Publisher.findAll().each (publisher)->           
      LIBS.models.PublisherReport.findAll({
        where: {
          interval: levels[interval][0]
          publisher_id: publisher.id
        }
      }).then (reports)->        
        LIBS.models.PublisherReport.merge(reports).then (report)->
          report.interval = interval
          report.publisher_id = publisher.id
          report.created_at = end_date
          
          if report.empty
            return Promise.reject "is_empty"

          LIBS.models.PublisherReport.create(report)
          
        .then ->
          LIBS.models.PublisherReport.destroy({
            where: {
              id: {
                $in: reports.map (report)->
                  return report.id
              }
            }
          })

        .catch (error)->
          if error != "is_empty"
            return Promise.reject error

