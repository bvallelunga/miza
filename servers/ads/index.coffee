app = require('express')()
ejs = require "ejs"

module.exports = (srv)->
  router = require("./router")(srv)

  # Express Setup
  app.engine 'js', ejs.renderFile
  app.engine 'ejs', ejs.renderFile
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use LIBS.bugsnag.requestHandler
  app.use router.core.auth.has_publisher
  app.use router.core.auth.has_opted_out
    
  
  # Routes  
  app.get "/check", router.core.check
  app.get "/p", router.core.ping
  app.get "/i", router.core.impression
  
  app.use router.engine
  app.use router.protect.prefix, router.protect.app
  app.use router.network.prefix, router.network.app
  
  
  # Error Handlers
  if CONFIG.is_prod
    app.use LIBS.bugsnag.errorHandler
  
  app.use require("./error")
  
  
  # Export
  return app