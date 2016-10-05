require("../startup") true, ->
  agenda = LIBS.agenda
  job_config = { timezone: CONFIG.timezone }

  # Define Jobs
  agenda.define "stripe.charge", {
    concurrency: 1
    priority: "highest"
  }, require("./stripe/charge")
  
  agenda.define "stripe.register", {
    concurrency: 1
    priority: "low"
  }, require("./stripe/register")
  
  agenda.define "reports.builder", {
    priority: "medium"
  }, require("./reports/builder")
  
  agenda.define "reports.reducer.hourly", {
    priority: "high"
  }, require("./reports/reducer")("hour")
  
  agenda.define "reports.reducer.daily", {
    priority: "high"
  }, require("./reports/reducer")("day")
  
  agenda.define "emails.publisher_report.weekly", {
    concurrency: 1
    priority: "medium"
  }, require("./emails/publisher_report")
  
  agenda.define "emails.add_payment_info.monthly", {
    concurrency: 1
    priority: "medium"
  }, require("./emails/add_payment_info")
  
  
  # 1st of the month
  agenda.every '30 0 1 * *', 'stripe.charge', {}, job_config
  
  
  # 1st of the Week
  agenda.every '30 0 * * 1', 'emails.publisher_report.weekly', {}, job_config  
  
  
  # 21st day of the month
  agenda.every '30 0 21 * *', 'emails.add_payment_info.monthly', {}, job_config  
  
  
  # Every day
  agenda.every '0 0 * * *', 'stripe.register', {}, job_config
  
  
  # End of every day
  agenda.every '59 23 * * *', 'reports.reducer.daily', {}, job_config
  
    
  # Every hour
  agenda.every '0 * * * *', 'reports.reducer.hourly', {}, job_config
  

  # Every minute
  agenda.every '* * * * *', 'reports.builder', {}, job_config
  
  
  # Start agenda
  agenda.start()
  
  
  # Graceful Shutdown
  graceful = ->
    agenda.stop ->
      process.exit 0
  
  process.on 'SIGTERM', graceful
  process.on 'SIGINT', graceful