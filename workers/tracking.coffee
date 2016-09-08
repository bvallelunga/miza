# Imports
geoip = require 'geoip-lite'
useragent = require 'user-agent-parser'


# Startup & Configure
require("../startup") true, ->
  
  # Bulk Creator
  to_save = []
    
  bulk_create = ->
    Promise.resolve().then ->
      list = to_save.splice 0, to_save.length
      
      if list.length == 0
        return Promise.resolve()
  
      LIBS.models.Event.bulkCreate(list, {
        hooks: false
        individualHooks: false
      })
    
    .then (reports)->   
      setTimeout bulk_create, CONFIG.tracking_worker.interval
      
    .catch console.error
    
  
  # Start Timer
  setTimeout bulk_create, CONFIG.tracking_worker.interval
      

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
      LIBS.mixpanel.track "ADS.EVENT.#{asset_type}", {
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
      
      if event.protected and event.type != "ping"
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
      
      # Add to Save List
      to_save.push event
    
    .then(ack).catch (error)->
      console.error error
      ack error
