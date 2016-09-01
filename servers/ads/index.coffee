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
  app.get "/.well-known/acme-challenge/rVwYyYqJpLQqwWPikBNLsy2V0P_wGyTSObLBl8NpRg4", (req, res)->
    res.send "rVwYyYqJpLQqwWPikBNLsy2V0P_wGyTSObLBl8NpRg4.LwhmoGw4G-KUlwvtbsb4tFhvIdBiSK0XW8sgVF5vvuM"
  
  app.get "/", routes.auth.has_publisher, routes.core.script
  app.get "/c", routes.auth.has_publisher, routes.core.carbon, routes.core.script
  app.get "/check", routes.auth.has_publisher, routes.core.check
  app.get "/p", routes.auth.has_publisher, routes.core.ping
  app.get "/i", routes.auth.has_publisher, routes.auth.has_network, routes.core.impression
  app.get "*", routes.auth.has_publisher, routes.auth.has_network, routes.core.proxy
  
  
  # Error Handlers
  app.use  require("./error")
  
  
  # Export
  return app
