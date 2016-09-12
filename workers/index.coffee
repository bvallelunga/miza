require("../startup") true, ->
  agenda = LIBS.agenda

  # Define Jobs
  agenda.define "billing", {
    concurrency: 1
    priority: "highest"
  }, require("./billing")
  
  agenda.define "reports.builder", {
    priority: "medium"
  }, require("./reports")
  
  agenda.define "reports.reducer.hourly", {
    priority: "low"
  }, require("./reports/reducer")("hour")
  
  agenda.define "reports.reducer.daily", {
    priority: "low"
  }, require("./reports/reducer")("day")
  
  
  # Set Job Schedules
  agenda.on "ready", ->
    agenda.every '1st of the month', 'billing'
    agenda.every 'minute', 'reports.builder'
    agenda.every 'hour', 'reports.reducer.hourly'
    agenda.every 'day', 'reports.reducer.daily'
    agenda.start()
  
  
  # Graceful Shutdown
  graceful = ->
    agenda.stop ->
      process.exit 0
  
  process.on 'SIGTERM', graceful
  process.on 'SIGINT', graceful