# Globals
GLOBAL.CONFIG = require("../config")
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()

LIBS.queue.consume "event-created", (message, ack, nack)->
  console.log message
  ack()