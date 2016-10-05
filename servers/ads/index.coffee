express = require 'express'
routes = require "./routes"
ejs = require "ejs"
app = express()

module.exports = (srv)->
  # Express Setup
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'js'
  app.engine 'js', ejs.renderFile
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use LIBS.bugsnag.requestHandler
  
  
  # Routes  
  app.get "/", routes.auth.has_publisher, routes.core.dfp, routes.core.script
  app.get "/c", routes.auth.has_publisher, routes.core.carbon, routes.core.script
  app.get "/check", routes.auth.has_publisher, routes.core.check
  app.get "/p", routes.auth.has_publisher, routes.core.ping
  app.get "/i", routes.auth.has_publisher, routes.auth.has_network, routes.core.impression
  app.get "*", routes.auth.has_publisher, routes.auth.has_network, routes.core.proxy
  
  
  # Error Handlers
  if CONFIG.is_prod
    app.use LIBS.bugsnag.errorHandler
  
  app.use require("./error")
  
  
  # Export
  return app
