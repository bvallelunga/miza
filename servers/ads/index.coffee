app = require('express')()
ejs = require "ejs"

module.exports = (srv)->
  router = require("./router")(srv)

  # Express Setup
  app.set 'view engine', 'js'
  app.engine 'js', ejs.renderFile
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use LIBS.bugsnag.requestHandler
  app.use router.core.auth.has_publisher
    
  
  # Routes  
  app.get "/check", router.core.check
  app.get "/p", router.core.ping
  app.get "/i", router.core.auth.has_network, router.core.impression
  
  app.use router.engine
  app.use router.protect.prefix, router.protect.app
  app.use router.network.prefix, router.network.app
  
  
  # Error Handlers
  if CONFIG.is_prod
    app.use LIBS.bugsnag.errorHandler
  
  app.use require("./error")
  
  
  # Export
  return app