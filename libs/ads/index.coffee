# Imports
useragent = require 'user-agent-parser'

module.exports.build_event = (req, data)->
  demensions = {}
  battery = {}
  advertiser = {}
  campaign = {}
  creative = {}
  industry = {}
  is_impr_or_click = data.type == "impression" or data.type == "click"
  
  Promise.resolve().then ->
    if not req.query.advertiser?
      return Promise.resolve()
  
    LIBS.models.Advertiser.findById(req.query.advertiser).then (temp)->
      if not temp?
        return Promise.resolve()
      
      advertiser = {
        id: temp.id
        key: temp.key
        name: temp.name
      }
      
  .then ->
    if not req.query.campaign?
      return Promise.resolve()
  
    LIBS.models.Campaign.findById(req.query.campaign).then (temp)->
      if not temp?
        return Promise.resolve()
        
      campaign = {
        id: temp.id
        name: temp.name
        type: temp.type
      }
      
      if is_impr_or_click
        temp[data.type + "s"] += 1
        temp.save()
        
  .then ->
    if not req.query.industry?
      return Promise.resolve()
  
    LIBS.models.CampaignIndustry.findById(req.query.industry).then (temp)->
      if not temp?
        return Promise.resolve()
        
      industry = {
        id: temp.id
        name: temp.name
        cpm: temp.cpm
        cpm_impression: temp.cpm_impression
      }
      
      if is_impr_or_click
        temp[data.type + "s"] += 1
        temp.save()
        
  .then ->
    if not req.query.creative?
      return Promise.resolve()
  
    LIBS.models.Creative.findById(req.query.creative).then (temp)->
      if not temp?
        return Promise.resolve()
        
      creative = {
        id: temp.id
        format: temp.format
      }
    
  .then ->
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
      advertiser: advertiser
      campaign: campaign
      creative: creative
      industry: industry
      page_url: {
        raw: req.query.page_url or req.get("referrer")
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
  
  LIBS.ads.build_event(req, data).then (event)->  
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
    if not data.publisher.is_activated
      data.publisher.update({
        is_activated: true
      })
  