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
    browser = Object.assign event.browser, agent.browser
    device = Object.assign event.device, agent.device
    
    # Insert new information
    browser.engine = agent.engine
    device.os = agent.os
    device.cpu = agent.cpu
    
    # Clean up old information
    browser.do_not_track = browser.do_not_track == "true"
    browser.demensions.width = Number(browser.demensions.width)
    browser.demensions.height = Number(browser.demensions.height)
    device.battery.charging = device.battery.charging == "true"
    device.battery.charging_time = Number(device.battery.charging_time)
    device.battery.level = Number(device.battery.level)
    
    return event.update({
      geo_location: geoip.lookup message.ip_address
      browser: browser
      device: device
    })
    
  .then(ack).catch(nack)