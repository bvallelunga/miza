# New Relic
require("newrelic")


# Config
GLOBAL.CONFIG = require("./config")()


# Enable Concurrency
module.exports = (concurrency, callback)->
  if concurrency
    require("throng") CONFIG.concurrency, ->
      startup callback
      
  else
    startup callback
      
    
  # Handle SIGTERM
  process.on 'SIGTERM', ->
    process.exit()
    
    
startup = (done)->
  # Globals
  GLOBAL.Promise = require "bluebird"
  Promise.config CONFIG.promises
  GLOBAL.LIBS = require("./libs")

  LIBS.init().then(done).catch (error)->
    console.error error.stack
    process.exit()