moment = require "moment"
numeral = require "numeral"
request = require "request"

module.exports.fetch = (req, res, next)->  
  LIBS.models.Campaign.findOne({
    where: {
      id: req.subdashboard or req.params.campaign
      advertiser_id: req.advertiser.id
    }
    include: [{
      model: LIBS.models.CampaignIndustry
      as: "industries"
    }, {
      model: LIBS.models.Creative
      as: "creatives"
    }]
  }).then (campaign)->
    if not campaign?
      return res.redirect "/demand/#{req.advertiser.key}/campaigns"
  
    if req.data?
      req.data.dashboard_width = "large"
      req.data.campaign = campaign
      req.data.js.push "keen", "data-table"
      req.data.css.push "keen", "data-table"
  
    req.campaign = campaign
    req.subdashboard = null
    res.locals.config.campaign = campaign.id
    next()
    
  .catch next
  

module.exports.post_update = (req, res, next)->
  Promise.resolve().then ->
    if req.body.action == "delete"
      return req.campaign.destroy()
      
    if req.campaign.status == "queued"
      if req.body.action == "running"
        req.campaign.start_at = new Date()
        
      else if req.body.action == "paused"
        return Promise.reject "Queued campaigns can not be paused"
      
    req.campaign.status = req.body.action
    req.campaign.save()
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
  

module.exports.get_industries = (req, res, next)->
  res.json {
    success: true
    results: req.campaign.industries.sort (a, b)->
      if(a.name < b.name) then return -1
      if(a.name > b.name) then return 1
      return 0
  }
  
  
module.exports.get_publishers = (req, res, next)->
  targeting = req.campaign.industries[0].targeting
  end_date = req.campaign.end_at
  
  if not end_date?
    today = new Date()
    shift = req.campaign.start_at
    
    if today > shift
      shift = today
    
    end_date = moment(shift).add(1, "month").toDate()

  LIBS.models.Publisher.findAll({
    where: {
      is_activated: true
    }
    order: "name ASC"
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).map (publisher)->
    if not targeting.blocked_publishers?
      targeting.blocked_publishers = []
  
    if targeting.blocked_publishers.indexOf(publisher.key) == -1
      status = "Enabled"
    else
      status = "Blocked"
      
    client = LIBS.keen.scopedAnalysis(publisher.config.keen)
  
    query = (type)->      
      client.query("count", {
        event_collection: "ads.event"
        timeframe: {
          start: req.campaign.start_at
          end: end_date
        }
        filters: [{
          "operator": "eq"
          "property_name": "campaign.id"
          "property_value": req.campaign.id
        },{
          "operator": "eq",
          "property_name": "type",
          "property_value": type
        }]
      }).then (response)->    
        return response.result
  
    return Promise.props({
      impressions: query "impression"
      clicks: query "click"
      ctr: 0
    }).then (metrics)->      
      metrics.ctr = numeral(metrics.clicks/Math.max(metrics.impressions or 1)).format("0[.]0%")
      metrics.impressions = numeral(metrics.impressions).format("0[,]000")
      metrics.clicks = numeral(metrics.clicks).format("0[,]000")
      
      return {
        id: publisher.key
        name: publisher.name
        status: status
        industry: publisher.industry.name
        metrics: metrics
      }
  
  .then (publishers)->
  
    res.json {
      success: true
      results: publishers
    }
    
  .catch next
  

module.exports.get_charts = (req, res, next)->
  client = LIBS.keen.scopedAnalysis req.advertiser.config.keen
  end_date = req.campaign.end_at
  
  if not end_date?
    today = new Date()
    shift = req.campaign.start_at
    
    if today > shift
      shift = today
    
    end_date = moment(shift).add(1, "month").toDate()
  
  query = (operation, query)->
    query.event_collection = "ads.event"
    query.timeframe = {
      start: req.campaign.start_at
      end: end_date
    }
    client.query(operation, query).then (response)->    
      return {
        success: true
        result: response
      }
  
  Promise.props({
    impressions_chart: query "count", {
      interval: "daily"
      group_by: [ "type" ]
      filters: [{
        "operator": "in",
        "property_name": "type",
        "property_value": [
          "click",
          "impression"
        ]
      }, {
        "operator": "eq"
        "property_name": "campaign.id"
        "property_value": req.campaign.id
      }]
    }
  }).then (charts)->
    res.json(charts) 
  
  .catch next
  
  
  
module.exports.post_industries = (req, res, next)->
  Promise.resolve().then ->
    if not req.campaign.active
      return Promise.reject """
        Campaign must be running to modify a specific industry.
      """
      
    LIBS.models.CampaignIndustry.findAll({
      where: {
        advertiser_id: req.advertiser.id
        campaign_id: req.campaign.id
        id: {
          $in: req.body.selected
        }
      }
    }).each (industry)->
      industry.update({
        status: req.body.action
      })
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
  
  
module.exports.post_publishers = (req, res, next)->
  Promise.resolve().then ->    
    LIBS.models.CampaignIndustry.findAll({
      where: {
        advertiser_id: req.advertiser.id
        campaign_id: req.campaign.id
      }
    }).each (industry)->
      targeting = industry.targeting
    
      if not targeting.blocked_publishers?
        targeting.blocked_publishers = []
    
      for publisher in req.body.selected
        index = targeting.blocked_publishers.indexOf(publisher)
        
        if index > -1
          targeting.blocked_publishers.splice(index, 1)
          
        if req.body.action == "block"
          targeting.blocked_publishers.push publisher
      
      industry.update({
        targeting: targeting
      })
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next


module.exports.post_create = (req, res, next)-> 
  if not req.body.creative.image_url.length > 0
    return next "Please make sure you have uploaded an image for your creative."
    
  if not req.body.creative.link.length > 0
    return next "Please make sure you have a click link for your creative."
  
  Promise.filter req.body.industries, (data)->
    data.impressions = Number data.impressions
    return data.activated == "true" and data.impressions > 0
    
  .map (data)->
    LIBS.models.Industry.findById(data.industry).then (industry)->
      return {
        industry: industry
        impressions: data.impressions
        targeting: req.body.targeting or {}
      }
    
  .then (targeting)->  
    if targeting.length == 0
      return Promise.reject "Please select at least 1 industry"
  
    start_date = moment(req.body.start_date, "MM-DD-YYYY")
    start_date = if start_date.isValid() then start_date.toDate() else null
    
    end_date = moment(req.body.end_date, "MM-DD-YYYY")
    end_date = if end_date.isValid() then end_date.toDate() else null
    
    status = if start_date then "queued" else "running"
    impressions_requested = 0
    is_house = req.body.is_house == "true" and req.user.is_admin
    
    for target in targeting
      impressions_requested += target.impressions
    
    LIBS.models.Campaign.create({
      name: req.body.name
      type: "cpm"
      status: status
      start_at: start_date or new Date()
      end_at: end_date
      advertiser_id: req.advertiser.id
      impressions_requested: impressions_requested
      config: {
        is_house: is_house
      }
    }).then (campaign)->    
      Promise.props({
        campaign: campaign
        industries: Promise.map targeting, (target)->
          LIBS.models.CampaignIndustry.create({
            status: campaign.status
            advertiser_id: req.advertiser.id
            campaign_id: campaign.id
            industry_id: target.industry.id
            name: target.industry.name
            impressions_requested: target.impressions
            cpm: if is_house then 0 else target.industry.cpm
            targeting: target.targeting
            config: {
              is_house: is_house
            }
          })
        
        creative: LIBS.models.Creative.fetch_image(req.body.creative.image_url).then (image)->
          trackers = req.body.creative.trackers.split("\n")
          
          if trackers.length == 1 and trackers[0].length == 0
            trackers = []
        
          LIBS.models.Creative.create({
            advertiser_id: req.advertiser.id
            campaign_id: campaign.id
            link: campaign.utm_link(req.body.creative.link)
            description: req.body.creative.description
            trackers: req.body.creative.trackers.split("\n")
            format: "300 x 250"
            image: image
          })
      })
      
  .then (data)->
    res.json({
      success: true
      next: "/demand/#{req.advertiser.key}/campaign/#{data.campaign.id}"
    })
    
  .catch next