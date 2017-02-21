# Imports
useragent = require 'user-agent-parser'

module.exports.build_event = (req, data)->
  demensions = {}
  battery = {}
  
  if req.query.demensions?
    demensions = {
      width: Number(req.query.demensions.width)
      height: Number(req.query.demensions.height)
    }
    
  if req.query.battery?
    battery = {
      charging: req.query.battery.charging == "true"
      charging_time: Number(req.query.battery.charging_time)
      level: Number(req.query.battery.level)
    }

  return {
    type: data.type 
    ip_address: req.headers["CF-Connecting-IP"] or req.ip or req.ips
    protected: req.query.protected == "true"
    asset_url: data.asset_url
    product: data.publisher.product
    publisher: {
      id: data.publisher.id
      name: data.publisher.name
      key: data.publisher.key
    }
    page_url: {
      raw: req.query.page_url
    }
    cookies: req.cookies
    headers: req.headers
    user_agent: {
      raw: req.headers["user-agent"]
      client: {
        browser: {
          demensions: demensions
          plugins: req.query.plugins or []
          languages: req.query.languages or []
          do_not_track: req.query.do_not_track == "true"
        }
        device: {
          components: req.query.components or []
          battery: battery
        }
      }
    }
    keen: {
      addons: [{
        name: "keen:ip_to_geo"
        input: {
          ip: "ip_address"
        },
        output: "location"
      }, {
        name: "keen:url_parser"
        input: {
          url: "page_url.raw"
        },
        output: "page_url.parsed"
      }, {
        name: "keen:ua_parser"
        input: {
          ua_string: "user_agent.raw"
        },
        output: "user_agent.parsed"
      }]
    }
  }


module.exports.track = (req, data)->
  agent = useragent req.headers['user-agent']
  event = LIBS.ads.build_event req, data
  
  # Keen Tracking
  LIBS.keen.tracking.addEvent "ads.event", event
  
  # Mixpanel Tracking
  asset_type = (event.type.split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '
  LIBS.mixpanel.track "ADS.EVENT.#{asset_type}", {
    distinct_id: "ads.#{event.ip_address}"
    $browser: agent.browser.name
    $browser_version: agent.browser.version
    $screen_width: event.user_agent.client.browser.demensions.width
    $screen_height: event.user_agent.client.browser.demensions.height
    $os: agent.os.name
    "Product": event.product
    "Protected": event.protected
    "Asset Type": event.type
    "Publisher ID": event.publisher.id
    "Publisher Name": event.publisher.name
    "Publisher Key": event.publisher.key
  }
  
  # Activate Publisher 
  if not data.publisher.is_activated
    data.publisher.update({
      is_activated: true
    })
  