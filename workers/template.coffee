module.exports = (init)->
  return (job, done)->
    Promise.resolve().then ->
      return init(job)

    .then(-> done()).catch (error)->
      if CONFIG.is_prod
        LIBS.bugsnag.notify error
      else
        console.error error.stack
        
      done error
