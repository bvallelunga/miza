app = require('express')()
ejs = require "ejs"
routes = require "./routes"

module.exports = (srv)->

  # Express Setup
  app.engine 'js', ejs.renderFile
  app.engine 'ejs', ejs.renderFile
  app.set 'view engine', 'ejs'
  app.set 'views', __dirname + '/views'
  
  app.use require("compression")()
  app.use routes.core.auth.has_publisher
  app.use routes.core.auth.has_opted_out
  app.use LIBS.bugsnag.requestHandler
    
  
  # Routes  
  app.get "/check", routes.core.check
  app.get "/p", routes.core.ping
  app.get "/i", routes.core.impression
  
  app.get "/", routes.network.script, routes.network.script_send
  app.get "/c", routes.network.script, routes.network.script_send
  app.get "/a", routes.network.script, routes.network.ad_frame
  app.get "/oo", routes.network.optout
  app.get "/*", routes.proxy
  
  
  # Error Handlers
  if CONFIG.is_prod
    app.use LIBS.bugsnag.errorHandler
  
  app.use require("./error")
  
  
  # Export
  return app