require("../../startup") false, ->  
  
  create_reports = ->  
    LIBS.models.Publisher.findAll({
      include: [{
        model: LIBS.models.Industry
        as: "industry"
      }]
    }).then (publishers)->           
      Promise.all publishers.map (publisher)->
        publisher.pending_events().then (props)->
          props.fee = publisher.industry.fee
          props.cpm = publisher.industry.cpm          
          return props
          
    .then (reports)->
      return {
        all: reports
        filtered: reports.filter (report)->
          return report.pings_all > 0 or report.revenue > 0
      }
  
    .then (reports)->
      LIBS.models.PublisherReport.bulkCreate(reports.filtered, {
        hooks: false
        individualHooks: false
        returning: false
      }).then ->
        return reports.all
      
    .then (reports)->    
      event_ids = [].concat.apply [], reports.map (report)->
        return report.events.map (event)->
          return event.id
    
      LIBS.models.Event.update {
        reported_at: new Date()
      }, {        
        where: {
          id: {
            $in: event_ids
          }
        }
      }
    
    .then ->
      setTimeout create_reports, CONFIG.reporting_worker.interval
      
    .catch console.error
  
  create_reports()