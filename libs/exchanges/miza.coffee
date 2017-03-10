module.exports = (req)->  
  query = {
    active: true
    impressions_needed: {
      $gt: 0
    }
  }

  if not req.publisher.is_demo
    query.industry_id = req.publisher.industry_id

  LIBS.models.CampaignIndustry.findAll({
    where: query
    limit: 10
    order: [
      ["impressions_needed", "DESC"]
    ]
  }).then (campaignIndustries)->  
    if campaignIndustries.length == 0
      return Promise.reject LIBS.exchanges.errors.AD_NOT_FOUND
    
    campaignIndustry = campaignIndustries[Math.floor(Math.random() * campaignIndustries.length)]
    
    LIBS.models.Creative.findOne({
      where: {
        advertiser_id: campaignIndustry.advertiser_id
        campaign_id: campaignIndustry.campaign_id
      }
    }).then (creative)->
      if not creative?
        return Promise.reject LIBS.exchanges.errors.NO_AD_FOUND
        
      creative.industry_id = campaignIndustry.id
      return creative