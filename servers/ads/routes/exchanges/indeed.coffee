module.exports = (req, res, next)->
  creative = LIBS.models.Creative.build()
  creative.id = "indeed"
  creative.campaign_id = "indeed"
  creative.advertiser_id = "indeed"
  
  LIBS.ads.event.track req, {
    type: "indeed.search"
  }
  
  LIBS.exchanges.indeed.listing(req.query.value, req).then (responses)->
    res.json {
      query: req.query.value 
      results: responses.results.map (job)->
        #job.url += "&jsa=#{job.onmousedown.split("'")[1]}&inchal=apiresults"
      
        return {
          #url: "/" + creative.click_link(req.publisher.id, null, req.query.protected, req.query.demo, job.url)
          url: job.url
          mousedown: job.onmousedown
          title: job.jobtitle
          location: "#{job.company} - #{job.formattedLocation}"
          description: job.snippet 
          posted_at: job.formattedRelativeTime
        }
    }
    
  .catch next