moment = require "moment"

module.exports.scrape = (req, res, next)-> 
  scraper = null

  switch req.body.format
    when "instagram_profile" 
      scraper = LIBS.scrapers.instagram.profile
      
    when "instagram_post" 
      scraper = LIBS.scrapers.instagram.post
    
    else 
      return next "Invalid campaign format type: #{req.body.format}"

  scraper(req.body.scrape_url).then (response)->
    res.json(response)
  .catch(next)


module.exports.create = (req, res, next)->   
  if req.body.creative.format == "300 x 250" and not req.body.creative.image_url.length > 0
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
        
        creative: Promise.resolve().then ->
          if req.body.creative.image_url.length > 0
            return LIBS.models.Creative.fetch_image(req.body.creative.image_url)
        
          return new Buffer(1)
        .then (image)->
          trackers = req.body.creative.trackers.split("\n")
          config = {}
          
          try
            config = JSON.parse(req.body.creative.config)
          
          if req.user.is_admin and req.body.creative.disable_incentive.length > 0
            config.disable_incentive = Number req.body.creative.disable_incentive
          
          if trackers.length == 1 and trackers[0].length == 0
            trackers = []
        
          LIBS.models.Creative.create({
            advertiser_id: req.advertiser.id
            campaign_id: campaign.id
            link: campaign.utm_link(req.body.creative.link)
            trackers: req.body.creative.trackers.split("\n")
            format: req.body.creative.format
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