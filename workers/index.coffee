require("../startup") true, ->
  agenda = LIBS.agenda

  # Define Jobs
  agenda.define "stripe.charge", {
    concurrency: 1
    priority: "highest"
  }, require("./stripe/charge")
  
  agenda.define "stripe.register", {
    concurrency: 1
    priority: "high"
  }, require("./stripe/register")
  
  agenda.define "reports.builder", {
    priority: "medium"
  }, require("./reports/builder")
  
  agenda.define "reports.reducer.hourly", {
    priority: "low"
  }, require("./reports/reducer")("hour")
  
  agenda.define "reports.reducer.daily", {
    priority: "low"
  }, require("./reports/reducer")("day")
  
  # Set Job Schedules
  agenda.every '1st of the month', 'stripe.charge'
  agenda.every 'minute', 'reports.builder'
  agenda.every 'hour', 'reports.reducer.hourly'
  agenda.every 'day', 'reports.reducer.daily'
  agenda.every 'day', 'stripe.register'
  agenda.start()
    
  
  # Graceful Shutdown
  graceful = ->
    agenda.stop ->
      process.exit 0
  
  process.on 'SIGTERM', graceful
  process.on 'SIGINT', graceful