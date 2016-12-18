app = require('express')()
routes = require "./routes"
core = require "../core"

module.exports = (srv)->
  # Express Setup
  app.set 'view engine', 'coffee'  
  app.set 'views', __dirname + '/views'
  
  # Routes  
#   app.get "/c", routes.protect.carbon, routes.protect.script
#   app.get "/*", routes.auth.has_network, routes.core.router
  
  # Export
  return app
