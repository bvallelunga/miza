express = require 'express'
routes = require "./routes"
ejs = require "ejs"
app = express()

module.exports = (srv)->
  # Express Setup
  app.use require("compression")()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'js'
  app.engine 'js', ejs.renderFile
  
  
  # Routes
  app.get "/", routes.auth.has_publisher, routes.core.script
  app.get "*", routes.auth.has_publisher, routes.core.proxy
  
  
  # Error Handlers
  app.use  require("./error")
  
  
  # Export
  return app
