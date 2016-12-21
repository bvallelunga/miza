module.exports = (config, method)->
  return {
    is_worker: not config.disabled
    init: ->
      for interval in config.intervals      
        LIBS.agenda.define interval[0], config.config, (job, done)->
          Promise.resolve().then ->
            return method(job)
      
          .then(-> done()).catch (error)->
            if CONFIG.is_prod
              LIBS.bugsnag.notify error
            
            else
              console.error error.stack
              
            done error
         
        if interval[1]   
          LIBS.agenda.every interval[1], interval[0], interval[2] or {}, { 
            timezone: CONFIG.timezone 
          }
  }