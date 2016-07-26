express = require 'express'
app = express()

module.exports = ->
  # Express Setup
  app.use require("compression")()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  
  
  # Public
  app.use "/test", express.static(__dirname + '/public/test')
  app.use "/imgs", express.static(__dirname + '/public/imgs')
  
  
  # Routes
  # app.get("/", sledge.identifier, sledge.script)
  # app.get("*", sledge.identifier, sledge.downloader, sledge.modifier)
  
  
  # Export
  return app
