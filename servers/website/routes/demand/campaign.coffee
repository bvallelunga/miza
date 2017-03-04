moment = require "moment"

module.exports.post_create = (req, res, next)->
  console.log req.body
  
  Promise.filter req.body.targeting, (data)->
    data.impressions = Number data.impressions
    return data.activated == "true" and data.impressions > 0
    
  .map (data)->
    LIBS.models.Industry.findById(data.id).then (industry)->
      return {
        industry: industry
        impressions: data.impressions
      }
    
  .then (targeting)->
    console.log targeting
  
    if targeting.length == 0
      return Promise.reject "Please select at least 1 industry"
  
    start_date = moment(req.body.start_date, "MM-DD-YYYY")
    start_date = if start_date.isValid() then start_date.toDate() else null
    
    end_date = moment(req.body.end_date, "MM-DD-YYYY")
    end_date = if end_date.isValid() then end_date.toDate() else null
    
    LIBS.models.Campaign.create({
      name: req.body.name
      type: "prepaid"
      status: "draft"
      start_date: start_date
      end_date: end_date
      advertiser_id: req.advertiser.id
    }).then (campaign)->
      Promise.map targeting, (target)->
        LIBS.models.CampaignIndustry.create({
          advertiser_id: req.advertiser.id
          campaign_id: campaign.id
          industry_id: target.industry.id
          name: target.industry.name
          impressions_requested: target.impressions
          cpm: target.industry.cpm
        })
      
      .then ->
        res.json({
          success: true
          next: "/demand/#{req.advertiser.key}/campaigns/#{campaign.id}"
        })
    
  .catch next