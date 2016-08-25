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
  
  
  # Routes
  app.get "/", routes.auth.has_publisher, routes.core.script
  app.get "/c", routes.auth.has_publisher, routes.core.carbon, routes.core.script
  app.get "/p", routes.auth.has_publisher, routes.core.ping
  app.get "/i", routes.auth.has_publisher, routes.auth.has_network, routes.core.impression
  app.get "*", routes.auth.has_publisher, routes.auth.has_network, routes.core.proxy
  
  
  # Error Handlers
  app.use  require("./error")
  
  
  # Export
  return app
