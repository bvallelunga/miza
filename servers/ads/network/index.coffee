app = require('express')()
routes = require "./routes"
core = require "../core"

module.exports = (srv)->
  # Express Setup
  app.set 'view engine', 'ejs'  
  app.set 'views', __dirname + '/views'
  
  
  # Routes  
  app.get "/", routes.script, routes.script_send
  app.get "/a", routes.script, routes.ad_frame
  app.get "/*", routes.proxy
  
  # Export
  return app
