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
  
  
  # Public
  require("../assets")(app, srv,  __dirname + '/public')
  app.use "/test", express.static(__dirname + '/public/test')
  app.use "/imgs", express.static(__dirname + '/public/imgs')
  
  
  # Routes
  app.get("/", routes.landing.root)
  
  
  # Export
  return app
