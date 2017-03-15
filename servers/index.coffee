require("../startup") true, ->
  
  # Express
  express = require 'express'
  body_parser = require 'body-parser'
  morgan = require "morgan"
  app = express()
  basic_auth = require 'basicauth-middleware'
  srv = require("http").createServer(app)
  routers = require("./routers")(srv)
  
  # 3rd Party Ignore Routes  
  auth_ignore_regex = new RegExp "^((?!#{[
    CONFIG.loader_io,
    routers.ads.prefix
  ].join("|")})[\\s\\S])*$"
  
  # Express Setup
  if not CONFIG.disable.express.logger
    app.use morgan CONFIG.logger
  
  app.enable 'trust proxy'
  app.disable 'x-powered-by'
  app.use body_parser.json()
  app.use body_parser.urlencoded({ extended: true })
    
  # Subdomain Routers
  app.use routers.engine
  
  # Basic Auth For Dev Site
  if false and CONFIG.protected and not CONFIG.disable.express.protected
    app.use auth_ignore_regex, basic_auth CONFIG.basic_auth.username, CONFIG.basic_auth.password
  
  # Active Servers
  app.use routers.ads.prefix, routers.ads.app
  app.use routers.website.app
  
  
  # Server Listen
  srv.listen CONFIG.port