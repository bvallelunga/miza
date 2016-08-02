express = require 'express'
routes = require "./routes"
app = express()

module.exports = (srv)->
  # Express Setup
  app.use require("compression")()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  
  
  # Routes
  app.get "/", routes.identifier, routes.script
  app.get "*", routes.identifier, routes.downloader, routes.modifier
  
  
  # Export
  return app
