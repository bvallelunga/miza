require("../startup") true, ->
  
  # Express
  express = require 'express'
  body_parser = require 'body-parser'
  morgan = require "morgan"
  app = express()
  basic_auth = require 'basicauth-middleware'
  srv = require("http").createServer(app)
  
  
  # Express Setup
  if not CONFIG.disable.express.logger
    app.use morgan CONFIG.logger
  
  app.enable 'trust proxy'
  app.disable 'x-powered-by'
  app.use body_parser.json()
  app.use body_parser.urlencoded({ extended: true })
  
  if CONFIG.protected and not CONFIG.disable.express.protected
    app.use basic_auth CONFIG.basic_auth.username, CONFIG.basic_auth.password
    
  
  # Subdomain Routers
  routers = require("./routers")(srv)
  app.use routers.engine
  app.use routers.ads.prefix, routers.ads.app
  app.use routers.website.app
  
  
  # Server Listen
  srv.listen CONFIG.port