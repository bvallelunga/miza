country_data = require 'country-data'
numeral = require "numeral"

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
    
    Promise.props({
      industries: LIBS.models.Industry.listed().then (industries)->
        req.data.industries = industries
        
      auto_bid: LIBS.models.Campaign.findAll({
        where: {
          status: {
            $ne: "completed"
          }
        }
      }).then (campaigns)->
        bid = 0
        auto_bid_min = 0.45
        
        for campaign in campaigns
          bid += campaign.amount
        
        bid = bid/campaigns.length
        bid += bid * 0.15

        req.data.auto_bid_min = numeral(auto_bid_min).format("0.00")
        req.data.auto_bid_max = numeral(bid + (bid * 0.5)).format("0.00")
        req.data.auto_bid = Number numeral(Math.max auto_bid_min, bid).format("0.00")
    }).then(-> next()).catch next
    
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
  

module.exports.builder = require "./builder"
