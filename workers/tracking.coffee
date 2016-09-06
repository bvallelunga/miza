# New Relic
require("newrelic")

# Config
GLOBAL.CONFIG = require("../config")()


# Imports
geoip = require 'geoip-lite'
useragent = require 'user-agent-parser'


# Download New Data
geoip.startWatchingDataUpdate()


# Enable Concurrency
require("throng") CONFIG.concurrency, ->
  
  # Globals
  GLOBAL.Promise = require "bluebird"
  Promise.config CONFIG.promises
  GLOBAL.LIBS = require("../libs")()

  
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
        
      
      if event.protected and ["impression", "click"].indexOf(event.type) > -1
        redis_key = "#{event.publisher.key}.events"
      
        LIBS.redis.get redis_key, (error, response)->  
          try
            events = JSON.parse(response) or []
          catch error
            events = []
            
          events.unshift {
            type: event.type
            network_name: event.network_name
            browser: browser.name or "Unknown"
            os: device.os.name or "Unknown"
            created_at: new Date()
          }
          
          LIBS.redis.set redis_key, JSON.stringify events.slice(0, 50)
        
      
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
