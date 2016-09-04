# New Relic
require("newrelic")

# Globals
GLOBAL.CONFIG = require("../config")()
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()


# Imports
geoip = require 'geoip-lite'
useragent = require 'user-agent-parser'


# Download New Data
geoip.startWatchingDataUpdate()


# Enable Concurrency
require("throng") CONFIG.concurrency, ->
  
  # Handle Queue Messges
  LIBS.queue.consume "event-queued", (event, ack, nack)->
    Promise.resolve().then ->    
      geo_location = geoip.lookup(event.ip_address) or {}
      agent = useragent event.headers['user-agent']  
      browser = Object.assign event.browser, agent.browser
      device = Object.assign event.device, agent.device
      asset_type = (event.type.split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '
      
      # Insert new information
      browser.engine = agent.engine
      device.os = agent.os
      device.cpu = agent.cpu
      
      # Clean up old information
      browser.demensions = browser.demensions or {}
      browser.demensions.width = Number(browser.demensions.width)
      browser.demensions.height = Number(browser.demensions.height)
      device.battery.charging = device.battery.charging == "true"
      device.battery.charging_time = Number(device.battery.charging_time)
      device.battery.level = Number(device.battery.level)
      
      # Mixpanel tracking
      mixpanel_payload = {
        distinct_id: "ads.#{event.ip_address}"
        $browser: browser.name
        $browser_version: browser.version
        $referrer: event.referrer_url
        $screen_width: browser.demensions.width
        $screen_height: browser.demensions.height
        $os: device.os.name
        $city: geo_location.city
        "Protected": event.protected
        "Asset Type": event.type
        "Network": event.network_name
        "Network ID": event.network_id
        "Publisher ID": event.publisher_id
        "Publisher Name": event.publisher.name
        "Publisher Key": event.publisher.key
      }
        
      if ["impression", "click", "ping"].indexOf(event.type) > -1
        LIBS.mixpanel.track "ADS.EVENT.#{asset_type}", mixpanel_payload
      
      event.geo_location = geo_location
      event.browser = browser
      event.device = device
      
      # Save Event Data
      return LIBS.models.Event.create event, {
        benchmark: false
        logging: false
      }
    
    .then ->
      setTimeout ack, 100
    
    .catch (error)->
      console.error error
      ack error
