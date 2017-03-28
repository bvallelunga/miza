# Imports
useragent = new require 'express-useragent'

module.exports.build_event = (raw_data)->
  demensions = {}
  battery = {}
  advertiser = {}
  campaign = {}
  creative = {}
  industry = {}
  
  # Clean Data
  for key, value of raw_data
    if value == "null" or value == "undefined" or value == ""
      raw_data[key] = null
  
  Promise.resolve().then ->
    if not raw_data.advertiser?
      return Promise.resolve()
  
    LIBS.models.Advertiser.findById(raw_data.advertiser).then (temp)->      
      advertiser = {
        id: temp.id
        key: temp.key
        name: temp.name
      }
      
  .then ->
    if not raw_data.campaign?
      return Promise.resolve()
  
    LIBS.models.Campaign.findById(raw_data.campaign).then (temp)->
      if not temp? then return
      
      campaign = {
        id: temp.id
        name: temp.name
        type: temp.type
      }
      
      if raw_data.type == "impression"
        temp.increment({
          "impressions": 1
          "impressions_needed": -1
        })
      
      if raw_data.type == "click"
        temp.increment("clicks")
        
  .then ->
    if not raw_data.industry?
      return Promise.resolve()
  
    LIBS.models.CampaignIndustry.findById(raw_data.industry).then (temp)-> 
      if not temp? then return
           
      industry = {
        id: temp.id
        name: temp.name
        cpm: temp.cpm
        cpm_impression: temp.cpm_impression
      }
      
      if raw_data.type == "impression"
        temp.increment({
          "impressions": 1
          "impressions_needed": -1
        })
      
      if raw_data.type == "click"
        temp.increment("clicks")
        
  .then ->
    if not raw_data.creative?
      return Promise.resolve()
  
    LIBS.models.Creative.findById(raw_data.creative).then (temp)->
      if not temp? then return
        
      creative = {
        id: temp.id
        format: temp.format
      }
    
  .then ->
    if raw_data.query.battery?
      battery = {
        charging: raw_data.query.battery.charging == "true"
        charging_time: Number(raw_data.query.battery.charging_time)
        level: Number(raw_data.query.battery.level)
      }
    
    return {
      type: raw_data.type 
      ip_address: raw_data.headers["CF-Connecting-IP"] or raw_data.ip or raw_data.ips
      session: raw_data.session
      protected: raw_data.query.protected == "true"
      asset_url: raw_data.asset_url
      product: raw_data.publisher.product
      publisher: {
        id: raw_data.publisher.id
        name: raw_data.publisher.name
        key: raw_data.publisher.key
      }
      advertiser: advertiser
      campaign: campaign
      creative: creative
      industry: industry
      page_url: {
        raw: raw_data.query.page_url or raw_data.referrer
      }
      user_agent: {
        raw: raw_data.headers["user-agent"]
#         client: {
#           browser: {
#             demensions: {
#               width: Number(raw_data.query.width)
#               height: Number(raw_data.query.height)
#             }
#             plugins: raw_data.query.plugins or []
#             languages: raw_data.query.languages or []
#             do_not_track: raw_data.query.do_not_track == "true"
#           }
#           device: {
#             components: raw_data.query.components or []
#             battery: battery
#           }
#         }
      }
      keen: {
        addons: [{
          name: "keen:ip_to_geo"
          input: {
            ip: "ip_address"
          },
          output: "location"
        }, {
          name: "keen:ua_parser"
          input: {
            ua_string: "user_agent.raw"
          },
          output: "user_agent.parsed"
        }]
      }
    }


module.exports.send = (raw_data)->
  if not raw_data.headers? or not raw_data.headers['user-agent']
    raw_data.headers = {}
    agent = {}
  
  else
    agent = useragent.parse(raw_data.headers['user-agent']) 
  
  if agent.os == "unknown" 
    agent.os = null
    
  if agent.browser == "unknown" 
    agent.browser = null
    
  if agent.version == "unknown" 
    agent.version = null
  
  LIBS.ads.build_event(raw_data).then (event)->    
    # Keen Tracking
    LIBS.keen.tracking.addEvent "ads.event", event
    
    # Mixpanel Tracking
    asset_type = (event.type.split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '
    LIBS.mixpanel.track "ADS.EVENT.#{asset_type}", {
      distinct_id: "ads.#{event.session}"
      $browser: agent.browser
      $browser_version: agent.version
      $screen_width: Number(raw_data.query.width)
      $screen_height: Number(raw_data.query.height)
      $os: agent.os 
      "Product": event.product
      "Protected": event.protected
      "Asset Type": event.type
      "Publisher ID": event.publisher.id
      "Publisher Name": event.publisher.name
      "Publisher Key": event.publisher.key
      "Industry ID": event.industry.id
      "Industry Name": event.industry.name
      "Industry CPM": event.industry.cpm
      "Advertiser ID": event.advertiser.id
      "Advertiser Name": event.advertiser.name
      "Advertiser Key": event.advertiser.key
      "Creative ID": event.creative.id
      "Creative Format": event.creative.format
      "Campaign ID": event.campaign.id
      "Campaign Name": event.campaign.name
      "Campaign Type": event.campaign.type
    }
    
    # Activate Publisher 
    if not raw_data.publisher.is_activated
      LIBS.models.Publisher.update({
        is_activated: true
      }, {
        individualHooks: true
        where: {
          id: raw_data.publisher.id
        }
      })

  
module.exports.track = (req, data)->
  data.advertiser = req.query.advertiser
  data.campaign = req.query.campaign
  data.industry = req.query.industry
  data.creative = req.query.creative
  data.headers = req.headers
  data.cookies = req.cookies
  data.query = req.query
  data.session = req.signedCookies.session
  data.referrer = req.get("referrer")
  data.ip = req.ip
  data.ips = req.ips
  
  LIBS.queue.publish "event-queue", data
