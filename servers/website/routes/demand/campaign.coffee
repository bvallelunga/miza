moment = require "moment"
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
    results: req.campaign.industries
  }
  

module.exports.get_charts = (req, res, next)->
  client = LIBS.keen.scopedAnalysis CONFIG.keen.readKey #(req.advertiser.config.keen)
  
  query = (operation, query)->
    query.event_collection = "ads.event"
    query.timeframe = "this_14_days" or {
      start: req.campaign.start_at
      end: req.campaign.end_at or moment(req.campaign.start_at).add(1, "month").toDate()
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
      }]# , {
#         "operator": "eq"
#         "property_name": "campaign.id"
#         "property_value": req.campaign.id
#       }]
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
          $in: req.body.industries
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


module.exports.post_create = (req, res, next)->  
  if not req.body.creative.image_url.length > 0
    return next "Please make sure you have uploaded an image for your creative."
    
  if not req.body.creative.link.length > 0
    return next "Please make sure you have a click link for your creative."
  
  Promise.filter req.body.targeting, (data)->
    data.impressions = Number data.impressions
    return data.activated == "true" and data.impressions > 0
    
  .map (data)->
    LIBS.models.Industry.findById(data.industry).then (industry)->
      return {
        industry: industry
        impressions: data.impressions
      }
    
  .then (targeting)->  
    if targeting.length == 0
      return Promise.reject "Please select at least 1 industry"
  
    start_date = moment(req.body.start_date, "MM-DD-YYYY")
    start_date = if start_date.isValid() then start_date.toDate() else null
    
    end_date = moment(req.body.end_date, "MM-DD-YYYY")
    end_date = if end_date.isValid() then end_date.toDate() else null
    
    status = if start_date then "queued" else "running"
    
    LIBS.models.Campaign.create({
      name: req.body.name
      type: "standard"
      status: status
      start_at: start_date or new Date()
      end_at: end_date
      advertiser_id: req.advertiser.id
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
            cpm: target.industry.cpm
          })
        
        creative: new Promise (res, rej)->
          request {
            method: "GET"
            encoding: null
            url: req.body.creative.image_url
          }, (error, response, body)=>
            if error?
              return rej error
          
            res response.body
        
        .then (image)->
          LIBS.models.Creative.create({
            advertiser_id: req.advertiser.id
            campaign_id: campaign.id
            link: req.body.creative.link
            description: req.body.creative.description
            trackers: req.body.creative.trackers.split("\n")
            image: image
          })
      })
      
  .then (data)->
    res.json({
      success: true
      next: "/demand/#{req.advertiser.key}/campaign/#{data.campaign.id}"
    })
    
  .catch next