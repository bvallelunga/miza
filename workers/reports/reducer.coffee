require("../../startup") false, -> 
  interval =  CONFIG.args[0] or "day"
  time =  if CONFIG.args[1]? then (CONFIG.args[1] * -1) else -1
  start_date = LIBS.helpers.past_date interval, null, time
  end_date = LIBS.helpers.past_date interval, null, time, "end"
  
  LIBS.models.Publisher.findAll().then (publishers)->           
    Promise.all publishers.map (publisher)->
      LIBS.models.PublisherReport.findAll({
        where: {
          publisher_id: publisher.id
          created_at: {
            $gte: start_date
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
  
  .then ->
    process.exit()

  .catch console.error