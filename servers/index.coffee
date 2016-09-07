require("../startup") true, ->
  
  # Express
  express = require 'express'
  bodyParser = require 'body-parser'
  morgan = require "morgan"
  app = express()
  srv = require("http").createServer(app)
  
  
  # Express Setup
  if not CONFIG.disable.express.logger
    app.use morgan CONFIG.logger
  
  app.enable 'trust proxy'
  app.use bodyParser.json()
  app.use bodyParser.urlencoded({ extended: true })
  
  
  # Subdomain Routers
  routers = require("./routers")(srv)
  app.use routers.engine
  app.use routers.ads.prefix, routers.ads.app
  app.use routers.website
  
  
  # Server Listen
  srv.listen CONFIG.port