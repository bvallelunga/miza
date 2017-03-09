# Startup & Configure
require("../../startup") true, ->

  LIBS.queue.consume "event-queue", (event, ack, nack)->   
    
    LIBS.ads.send(event).then(ack).catch (error)->
      LIBS.bugsnag.notify error
      nack error
    