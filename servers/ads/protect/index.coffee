app = require('express')()
routes = require "./routes"
core = require "../core"

module.exports = (srv)->
  # Express Setup
  app.set 'views', __dirname + '/views'
  
  # Routes  
  app.get "/c", routes.carbon, routes.script
  app.get "/*", core.auth.has_network, routes.proxy
  
  # Export
  return app
