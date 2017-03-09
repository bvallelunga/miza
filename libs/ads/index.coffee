# Imports
useragent = require 'user-agent-parser'

module.exports.build_event = (raw_data)->
  demensions = {}
  battery = {}
  advertiser = {}
  campaign = {}
  creative = {}
  industry = {}
  is_impr_or_click = raw_data.type == "impression" or raw_data.type == "click"
  
  Promise.resolve().then ->
    if not raw_data.query.advertiser?
      return Promise.resolve()
  
    LIBS.models.Advertiser.findById(raw_data.advertiser).then (temp)->      
      advertiser = {
        id: temp.id
        key: temp.key
        name: temp.name
      }
      
  .then ->
    if not raw_data.query.campaign?
      return Promise.resolve()
  
    LIBS.models.Campaign.findById(raw_data.campaign).then (temp)->
      campaign = {
        id: temp.id
        name: temp.name
        type: temp.type
      }
      
      if is_impr_or_click
        temp[raw_data.type + "s"] += 1
        temp.save()
        
  .then ->
    if not raw_data.query.industry?
      return Promise.resolve()
  
    LIBS.models.CampaignIndustry.findById(raw_data.industry).then (temp)->        
      industry = {
        id: temp.id
        name: temp.name
        cpm: temp.cpm
        cpm_impression: temp.cpm_impression
      }
      
      if is_impr_or_click
        temp[raw_data.type + "s"] += 1
        temp.save()
        
  .then ->
    if not raw_data.query.creative?
      return Promise.resolve()
  
    LIBS.models.Creative.findById(raw_data.creative).then (temp)->
      if not temp?
        return Promise.resolve()
        
      creative = {
        id: temp.id
        format: temp.format
      }
    
  .then ->
    if raw_data.query.demensions?
      demensions = {
        width: Number(raw_data.query.demensions.width)
        height: Number(raw_data.query.demensions.height)
      }
      
    if raw_data.query.battery?
      battery = {
        charging: raw_data.query.battery.charging == "true"
        charging_time: Number(raw_data.query.battery.charging_time)
        level: Number(raw_data.query.battery.level)
      }
    
    return {
      type: raw_data.type 
      ip_address: raw_data.headers["CF-Connecting-IP"] or raw_data.ip or raw_data.ips
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
      cookies: raw_data.cookies
      headers: raw_data.headers
      user_agent: {
        raw: raw_data.headers["user-agent"]
        client: {
          browser: {
            demensions: demensions
            plugins: raw_data.query.plugins or []
            languages: raw_data.query.languages or []
            do_not_track: raw_data.query.do_not_track == "true"
          }
          device: {
            components: raw_data.query.components or []
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


module.exports.send = (raw_data)->
  agent = useragent raw_data.headers['user-agent']
  
  LIBS.ads.build_event(raw_data).then (event)->    
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
  data.query = req.query
  data.cookies = req.cookies
  data.headers = req.headers
  data.referrer = req.get("referrer")
  data.ip = req.ip
  data.ips = req.ips
  
  LIBS.queue.publish "event-queue", data
