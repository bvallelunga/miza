app = require('express')()
#routes = require "./routes"

module.exports = (srv)->
  # Express Setup
  app.set 'views', __dirname + '/views'
  
  # Routes  
#   app.get "/c", routes.protect.carbon, routes.protect.script
#   app.get "/*", routes.auth.has_network, routes.core.router
  
  # Export
  return app
