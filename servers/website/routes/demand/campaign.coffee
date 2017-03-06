moment = require "moment"
request = require "request"

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
    
    LIBS.models.Campaign.create({
      name: req.body.name
      type: "standard"
      status: "draft"
      start_at: start_date
      end_at: end_date
      advertiser_id: req.advertiser.id
    }).then (campaign)->
      Promise.props({
        campaign: campaign
        industries: Promise.map targeting, (target)->
          LIBS.models.CampaignIndustry.create({
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
      next: "/demand/#{req.advertiser.key}/campaigns/#{data.campaign.id}"
    })
    
  .catch next