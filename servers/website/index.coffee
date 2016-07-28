express = require 'express'
session = require 'express-session'
routes = require "./routes"
app = express()


module.exports = (srv)->
  # Express Setup
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use require("csurf")({ cookie: true })
  app.use require('express-session')(CONFIG.cookies.session session, LIBS.redis)
  app.use require("./locals")
  app.use require("./error")
  
  
  # Public
  require("../assets")(app, srv,  __dirname + '/public')
  app.use "/test", express.static(__dirname + '/public/test')
  app.use "/imgs", express.static(__dirname + '/public/images')
  
  
  # Routes
  app.get  "/", routes.landing.get_root
  app.post "/beta", routes.landing.post_beta
  
  app.get  "/login", routes.auth.get_login
  app.post "/login", routes.auth.post_login
  
  app.get  "/dashboard", routes.dashboard.get_root
  app.get  "/dashboard/:dashboard", routes.dashboard.get_root
  
  
  # Export
  return app
