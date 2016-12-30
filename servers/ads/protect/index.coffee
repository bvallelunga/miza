app = require('express')()
routes = require "./routes"

module.exports = (srv)->
  # Express Setup
  app.set 'view engine', 'js'
  app.set 'views', __dirname + '/views'
  
  # Routes  
  app.get "/", routes.abtest, routes.script
  app.get "/c", routes.abtest, routes.script
  app.get "/*", routes.proxy
  
  
  # Export
  return app
