app = require('express')()
routes = require "./routes"
core = require "../core"

module.exports = (srv)->
  # Express Setup
  app.set 'view engine', 'ejs'  
  app.set 'views', __dirname + '/views'
  
  
  # Routes  
  app.get "/", routes.script
  app.get "/a", routes.ad_frame

  app.use "/*", routes.notfound
  
  # Export
  return app
