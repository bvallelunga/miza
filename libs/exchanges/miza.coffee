moment = require "moment"

module.exports = (req)->  
  profile = LIBS.exchanges.utils.profile(req)
  
  # Disable ads for bots
  if profile.agent.isBot
    return Promise.reject LIBS.exchanges.errors.BOT_FOUND
    
  # Width Check
  if Number(req.query.width) > 500
    return Promise.reject LIBS.exchanges.errors.NO_AD_FOUND
    
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
    }
    
    # Campaign Blocking
    blocked_campaigns = req.signedCookies.clicked_campaigns or []
    viewed_campaigns = req.signedCookies.viewed_campaigns or {}
    
    for id, viewed_at of viewed_campaigns
      if moment.duration(new Date() - new Date(viewed_at)).asHours() < 2
        blocked_campaigns.push Number id
    
    if not req.publisher.is_demo and blocked_campaigns.length > 0
      query.campaign_id = {
        $notIn: blocked_campaigns
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
    # Grab a random set of 5 campaigns
    # Then we sort the 5 campaigns by bid
    # 70% of the time the highest bid will
    # be shown. 30% of the time the a random
    # creative will be chosen
    LIBS.models.CampaignIndustry.findAll({
      where: query
      limit: 5
      order: [
        LIBS.models.Sequelize.fn('RANDOM')
        ["updated_at", "ASC"]
      ]
    }).then (campaignIndustries)->  
      if campaignIndustries.length == 0
        return Promise.reject LIBS.exchanges.errors.AD_NOT_FOUND
      
      # 20% of the time we show select a random bid
      # this is done to ensure the low bids get
      # some impressions
      if Math.random() <= 0.70
        campaignIndustries = campaignIndustries.sort (a, b)->
          return b.amount - a.amount
        
      else
        campaignIndustries = LIBS.helpers.shuffle campaignIndustries
      
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
