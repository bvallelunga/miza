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
    
    
startup = (callback)->
  # Globals
  GLOBAL.Promise = require "bluebird"
  Promise.config CONFIG.promises
  
  require("./libs")().then (LIBS)->
    GLOBAL.LIBS = LIBS
    callback()
    
  .catch (error)->
    console.error error
    process.exit()