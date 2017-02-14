# Imports
geoip = require 'geoip-lite'
useragent = require 'user-agent-parser'


# Startup & Configure
require("../../startup") true, ->

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
      
      # Segment Tracking 
      LIBS.segment.ads.track {
        userId: "ads.#{event.ip_address}"
        event: "EVENT.#{asset_type}"
        properties: {
          browser: browser.name
          browser_version: browser.version
          referrer: event.referrer_url
          screen_width: browser.demensions.width
          screen_height: browser.demensions.height
          os: device.os.name
          city: geo_location.city
          product: event.publisher.product
          protected: event.protected
          asset_type: event.type
          publisher_id: event.publisher_id
          publisher_name: event.publisher.name
          publisher_key: event.publisher.key
        }
      }
      
      # Mixpanel tracking
      LIBS.mixpanel.track "ADS.EVENT.#{asset_type}", {
        distinct_id: "ads.#{event.ip_address}"
        $browser: browser.name
        $browser_version: browser.version
        $referrer: event.referrer_url
        $screen_width: browser.demensions.width
        $screen_height: browser.demensions.height
        $os: device.os.name
        $city: geo_location.city
        "Product": event.publisher.product
        "Protected": event.protected
        "Asset Type": event.type
        "Publisher ID": event.publisher_id
        "Publisher Name": event.publisher.name
        "Publisher Key": event.publisher.key
      }
      
      if not event.publisher.is_activated
        LIBS.models.Publisher.update {
          is_activated: true
        }, {
          individualHooks: true
          where: {
            id: event.publisher.id
          }
        }
      
      if event.protected and event.type != "ping"
        redis_key = "publisher.#{event.publisher.key}.events"
      
        LIBS.redis.get redis_key, (error, response)->  
          try
            events = JSON.parse(response) or []
          catch error
            events = []
            
          events.unshift {
            type: event.type
            browser: browser.name or "Unknown"
            os: device.os.name or "Unknown"
            created_at: new Date()
          }
          
          LIBS.redis.set redis_key, JSON.stringify events.slice(0, 50)
        
      
      event.geo_location = geo_location
      event.browser = browser
      event.device = device
      
      # Save Event
      return LIBS.models.Event.create event
    
    .then(ack).catch (error)->
      console.error error.stack
      ack error
      
      if CONFIG.is_prod
        LIBS.bugsnag.notify error
