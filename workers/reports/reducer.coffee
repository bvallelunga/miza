module.exports = (interval)->
  interval = interval or "day"
  levels = {
    day: ["minute", "hour"]
    hour: ["minute"]
  }

  return require("../template") (job)-> 
    data = job.attrs.data or {}
    time =  if data.time? then (data.time * -1) else -1
    end_date = LIBS.helpers.past_date interval, null, time, "end"
    
    if Object.keys(levels).indexOf(interval) == -1
      return Promise.reject "Invalid interval"
    
    LIBS.models.Publisher.findAll().then (publishers)->           
      Promise.all publishers.map (publisher)->      
        LIBS.models.PublisherReport.findAll({
          where: {
            interval: {
              $in: levels[interval]
            }
            publisher_id: publisher.id
            created_at: {
              $lte: end_date
            }
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

