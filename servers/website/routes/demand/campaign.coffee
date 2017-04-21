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
      model: LIBS.models.Creative
      as: "creatives"
    }]
  }).then (campaign)->
    if not campaign?
      return res.redirect "/demand/#{req.advertiser.key}/campaigns"
  
    if req.data?
      req.data.dashboard_width = "large"
      req.data.campaign = campaign
      req.data.js.push "keen", "data-table", "tooltip"
      req.data.css.push "keen", "data-table", "tooltip"
  
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
  req.campaign.getIndustries({
    sort: "name ASC"
  }).then (industries)->
    res.json {
      success: true
      results: industries
    }
  
  .catch next
  
  
module.exports.get_publishers = (req, res, next)->
  req.campaign.getIndustries().then (industries)->
    targeting = industries[0].targeting
    end_date = req.campaign.end_at or new Date()
  
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
                
      return {
        id: publisher.key
        name: publisher.name
        status: status
        industry: publisher.industry.name
      }
    
  .then (publishers)->
    res.json {
      success: true
      results: publishers
    }
      
  .catch next
  

module.exports.get_charts = (req, res, next)->
  end_date = req.campaign.end_at or new Date()
  month_timeframe = JSON.stringify({
    start: moment.utc(req.campaign.start_at).startOf("day").toISOString()
    end: moment.utc(end_date).add(2, "day").startOf("day").toISOString()
  })
  
  query = (query_name)->
    LIBS.keen.fetchDataset(query_name, {
      index_by: String(req.campaign.id)
      timeframe: month_timeframe
    }).catch (error)->
      LIBS.bugsnag.notify error
      console.log error
      return LIBS.keen.errors.DATA
  
  Promise.props({
    impressions_chart: Promise.all([
      query "campaign-impression-chart"
      query "campaign-click-chart"
    ])
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