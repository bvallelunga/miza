express = require 'express'
bodyParser = require 'body-parser'
morgan = require "morgan"
app = express()

# Globals
GLOBAL.Libs = require("./libs")


# Express Setup
app.use morgan(':method :url :response-time')
app.enable 'trust proxy'
app.use bodyParser.json()
app.use bodyParser.urlencoded({
  extended: true
})


# Subdomain Routers
routers = require("./express/routers")()
app.use routers.engine
app.use routers.sledge.prefix, routers.sledge.app
app.use routers.website


# Listen
app.listen Libs.env.PORT or 3030
