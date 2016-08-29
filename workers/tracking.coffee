geoip = require 'geoip-lite'
useragent = require 'user-agent-parser'

# Globals
GLOBAL.CONFIG = require("../config")()
GLOBAL.Promise = require "bluebird"
Promise.config CONFIG.promises
GLOBAL.LIBS = require("../libs")()

# Download New Data
geoip.startWatchingDataUpdate()

# Handle Queue Messges
LIBS.queue.consume "event-created", (event, ack, nack)->
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
      "Asset URL": event.asset_url
      "Asset Type": event.type
      "Network": event.network_name
      "Network ID": event.network_id
      "Publisher ID": event.publisher_id
    }
      
    if ["impression", "click", "ping"].indexOf(event.type) > -1
      LIBS.mixpanel.track("ADS.EVENT", mixpanel_payload)
      LIBS.mixpanel.track("ADS.EVENT.#{asset_type}", mixpanel_payload)
    
    
    # Save Event Data
    return LIBS.models.Event.update({
      geo_location: geo_location
      browser: browser
      device: device
    }, {
      where: {
        id: event.id
      }
    })
  
  .then(ack).catch (error)->
    console.error error
    nack error
