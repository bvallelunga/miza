module.exports = (req)->  
  profile = LIBS.exchanges.utils.profile(req)
  
  # Disable ads for bots
  if profile.agent.isBot
    return Promise.reject LIBS.exchanges.errors.BOT_FOUND
    
  Promise.resolve().then ->
    # Check if there is a creative override
    if req.query.creative_override
      return LIBS.models.Creative.findById(req.query.creative_override)
    
    return false
  .then (creative)->
    if creative then return creative
  
    # Build query
    query = {
      active: true
      impressions_needed: {
        $gt: 0
      }
    }
    
    # Industry Targeting
    if not req.publisher.is_demo
      query.industry_id = req.publisher.industry_id
      
    # Publisher NOT Targeting
    query["targeting.blocked_publishers"] = {
      $or: [
        {
          $eq: null
        }
        {
          $notLike: "%#{'"' + req.publisher.key + '"'}%"
        }
      ]
    }  
    
    # Additional Targeting
    targets = ["devices", "os", "browsers", "countries", "days"]
    
    for target in targets
      if profile[target]
        query["targeting.#{target}"] = {
          $or: [
            {
              $eq: null
            }
            {
              $like: "%#{'"' + profile[target] + '"'}%"
            }
          ]
        }
  
    # Find Campaign Industries
    LIBS.models.CampaignIndustry.findAll({
      where: query
      limit: 1
      order: [
        LIBS.models.Sequelize.fn('RANDOM')
        ["created_at", "DESC"]
        ["impressions_needed", "DESC"]
      ]
    }).then (campaignIndustries)->  
      if campaignIndustries.length == 0
        return Promise.reject LIBS.exchanges.errors.AD_NOT_FOUND
      
      campaignIndustry = campaignIndustries[0]
      
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
