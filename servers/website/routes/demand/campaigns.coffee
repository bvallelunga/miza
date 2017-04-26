country_data = require 'country-data'

module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range")
  req.data.css.push("date-range")
  req.data.dashboard_width = "medium"
  req.data.format = req.query.format or "image"
  req.data.config = {
    advertiser: req.advertiser.key
  }
  
  if not req.subdashboard
    req.data.js.push("data-table")
    req.data.css.push("data-table")
    req.subdashboard = "listing"
    next()
    
  else if req.subdashboard == "create" 
    req.subdashboard = "builder"
    req.data.css.push("chosen-select")
    req.data.js.push("modal", "chosen-select")
    req.data.country_data = country_data
    req.data.approved_countries = [
      "us", "ca", "mx", "de", "gb",
      "tr", "nz", "fr", "au", "se",
      "ph", "in", "cn", "jp", "no",
      "dk", "fi"
    ]
    
    LIBS.models.Industry.listed().then (industries)->
      req.data.industries = industries
      next()
    
    .catch next
    
  else
    res.redirect "/demand/#{req.advertiser.key}/campaigns"
  
  
module.exports.post_updates = (req, res, next)->
  Promise.resolve().then ->    
    if req.body.action == "delete"
      return LIBS.models.Campaign.destroy({
        individualHooks: true
        where: {
          advertiser_id: req.advertiser.id
          id: {
            $in: req.body.campaigns
          }
        }
      })
    
    
    LIBS.models.Campaign.findAll({
      where: {
        advertiser_id: req.advertiser.id
        id: {
          $in: req.body.campaigns
        }
        status: {
          $ne: "completed"
        }
      }
    }).each (campaign)->
      if campaign.status == "queued"
        if req.body.action == "running"
          campaign.start_at = new Date()
          
        else if req.body.action == "paused"
          return Promise.reject "Queued campaigns can not be paused"
        
      campaign.status = req.body.action
      campaign.save()
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
  
  
module.exports.post_list = (req, res, next)->
  req.advertiser.getCampaigns({
    where: {
      $or: [{
        start_at: {
          $gte: new Date req.body.dates.start
          $lte: new Date req.body.dates.end
        }
      }, {
        status: "running"
        start_at: {
          $lte: new Date req.body.dates.start
        }
      }]
    }
    include: [{
      model: LIBS.models.CampaignIndustry
      as: "industries"
    }]
    order: [
      ["created_at", "DESC"]
    ]
  }).then (campaigns)->
    res.json {
      success: true
      results: campaigns
    }
    
  .catch next
  

module.exports.post_create = (req, res, next)-> 
  if not req.body.creative.image_url.length > 0
    return next "Please make sure you have uploaded an image for your creative"
    
  if not req.body.creative.link.length > 0
    return next "Please make sure you have a click link for your creative"
      
  Promise.resolve().then ->
    query = {
      private: false
      max_impressions: {
        $gt: 0
      }
    }
    
    if req.body.industries? and req.body.industries.length > 0
      query = {
        id: {
          $in: req.body.industries.map (id)-> Number id
        }
      }
  
    LIBS.models.Industry.findAll({
      where: query
    })
  .then (targeting)->    
    bid = Number req.body.bid
    budget = Number req.body.budget
    
    if bid == NaN
      return Promise.reject "Please make sure you entered a valid bid"
      
    if bid < 0.02
      return Promise.reject "Please make sure your bid is at least $0.02"
      
    if budget == NaN
      return Promise.reject "Please make sure you entered a valid budget"
      
    if budget < 2
      return Promise.reject "Please make sure your budget is at least $2"
    
    start_date = moment(req.body.start_date, "MM-DD-YYYY")
    start_date = if start_date.isValid() then start_date.startOf("day").toDate() else null
    
    end_date = moment(req.body.end_date, "MM-DD-YYYY")
    end_date = if end_date.isValid() then end_date.endOf("day").toDate() else null
    
    is_house = req.body.is_house == "true" and req.user.is_admin
    temp_bid = if req.body.model == "cpm" then bid/1000 else bid
    quantity_requested = Math.floor(budget/temp_bid)
    status = if start_date then "queued" else "running"
    
    LIBS.models.Campaign.create({
      name: req.body.name
      type: req.body.model
      status: status
      start_at: start_date or new Date()
      end_at: end_date
      advertiser_id: req.advertiser.id
      amount: if is_house then 0 else bid
      quantity_requested: quantity_requested
      config: {
        is_house: is_house
        targeting: req.body.targeting or {}
      }
    }).then (campaign)->    
      Promise.props({
        campaign: campaign
        industries: Promise.map targeting, (industry)->
          LIBS.models.CampaignIndustry.create({
            type: req.body.model
            status: campaign.status
            advertiser_id: req.advertiser.id
            campaign_id: campaign.id
            industry_id: industry.id
            name: industry.name
            amount: if is_house then 0 else bid
            targeting: req.body.targeting or {}
            config: {
              is_house: is_house
            }
          })
        
        creative: LIBS.models.Creative.fetch_image(req.body.creative.image_url).then (image)->
          trackers = req.body.creative.trackers.split("\n")
          config = {}
          
          if req.user.is_admin and req.body.creative.disable_incentive.length > 0
            config.disable_incentive = Number req.body.creative.disable_incentive
          
          if trackers.length == 1 and trackers[0].length == 0
            trackers = []
        
          LIBS.models.Creative.create({
            advertiser_id: req.advertiser.id
            campaign_id: campaign.id
            link: campaign.utm_link(req.body.creative.link)
            trackers: req.body.creative.trackers.split("\n")
            format: "300 x 250"
            image: image
            config: config
          })
      })
      
  .then (data)->
    res.json({
      success: true
      next: "/demand/#{req.advertiser.key}/campaign/#{data.campaign.id}"
    })
    
  .catch next