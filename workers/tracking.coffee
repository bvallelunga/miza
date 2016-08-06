geoip = require 'geoip-lite'
useragent = require 'user-agent-parser'

# Globals
GLOBAL.CONFIG = require("../config")
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()

# Download New Data
geoip.startWatchingDataUpdate()

# Handle Queue Messges
LIBS.queue.consume "event-created", (message, ack, nack)->
  LIBS.models.Event.findById(message.id).then (event)->
    agent = useragent message.headers['user-agent']    
    browser = agent.browser
    device = agent.device
    
    browser.engine = agent.engine
    device.os = agent.os
    device.cpu = agent.cpu
    
    return event.update({
      geo_location: geoip.lookup message.ip_address
      browser: browser
      device: device
    })
    
  .then(ack).catch(nack)