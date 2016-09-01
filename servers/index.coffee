# Globals
GLOBAL.CONFIG = require("../config")()
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()

# Express
express = require 'express'
bodyParser = require 'body-parser'
morgan = require "morgan"
app = express()

require("./ssl")().then (lex)->
  server = require('http').createServer app
  server_ssl = require("https").createServer lex.httpsOptions, lex.middleware(app)
  
  # Express Setup
  if not CONFIG.disable.express.logger
    app.use morgan CONFIG.logger
  
  app.enable 'trust proxy'
  app.use bodyParser.json()
  app.use bodyParser.urlencoded({ extended: true })
  
  
  # Subdomain Routers
  routers = require("./routers")(server)
  app.use routers.engine
  app.use routers.ads.prefix, routers.ads.app
  app.use routers.website
  
  
  # Server Listen
  server.listen CONFIG.port
  server_ssl.listen 443