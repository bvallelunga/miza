# Startup & Configure
require("../../startup") true, ->
  queues = [{
    name: "event"
    method: LIBS.ads.event.send
  }, {
    name: "visitor"
    method: LIBS.ads.visitor.send
  }]

  queues.forEach (queue)->
    LIBS.queue.consume "#{queue.name}-queue", (event, ack, nack)->               
      queue.method(event).then(ack).catch (error)->
        LIBS.bugsnag.notify error
        console.log error.stack
        nack error
        