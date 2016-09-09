require("../../startup") false, -> 
  interval =  CONFIG.args[0] or "day"
  time =  (-1 * CONFIG.args[1]) or -1
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
  
  .then ->
    process.exit()

  .catch console.error