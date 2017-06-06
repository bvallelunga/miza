module.exports = (req, res, next)->
  creative = LIBS.models.Creative.build()
  
  LIBS.ads.event.track req, {
    type: "indeed.search"
  }
  
  LIBS.exchanges.indeed.listing(req.query.value, req).then (responses)->
    res.json {
      query: req.query.value 
      results: responses.results.map (job)->
        return {
          url: "/" + creative.attributed_link(req.publisher.id, null, req.query.protected, req.query.demo, job.url)
          title: job.jobtitle
          location: "#{job.company} - #{job.formattedLocation}"
          description: job.snippet 
          posted_at: job.formattedRelativeTime
        }
    }
    
  .catch next