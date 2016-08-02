express = require 'express'
bodyParser = require 'body-parser'
morgan = require "morgan"
app = express()
srv = require("http").createServer(app)


# Globals
GLOBAL.Promise = require "bluebird"
GLOBAL.CONFIG = require("./config")
GLOBAL.LIBS = require("./libs")()


# Promise Config
Promise.config CONFIG.promises


# Express Setup
app.use morgan(':method :url :response-time')
app.enable 'trust proxy'
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: true })


# Subdomain Routers
routers = require("./servers/routers")(srv)
app.use routers.engine
app.use routers.ads.prefix, routers.ads.app
app.use routers.website


# Server Listen
srv.listen CONFIG.port or 3030
