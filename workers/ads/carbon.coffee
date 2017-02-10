# Startup & Configure
require("../../startup") true, ->

  LIBS.queue.consume "carbon-mimic", (event, ack, nack)->    
    LIBS.exchanges.carbon.fetch_content().then ->
      ack()
    .catch (error)->
      console.error error.stack
      ack error
      
      if CONFIG.is_prod
        LIBS.bugsnag.notify error
