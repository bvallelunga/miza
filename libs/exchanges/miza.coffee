moment = require "moment"

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
      where: {
        active: true 
      }
      includes: []
    }
    
    
    # Creative Demensions
    creative_width = parseInt(req.query.width) or 300
      
    query.includes.push({
      model: LIBS.models.Creative
      as: "creatives"
      required: true
      where: {
        width: {
          $lte: creative_width
          $gte: creative_width * 0.85
        }
      }
    })
  
    
    # Campaign Blocking
    blocked_campaigns = req.signedCookies.clicked_campaigns or []
    viewed_campaigns = req.signedCookies.viewed_campaigns or {}
    
    for id, viewed_at of viewed_campaigns
      if moment.duration(new Date() - new Date(viewed_at)).asHours() < 2
        blocked_campaigns.push Number id
    
    if not req.publisher.is_demo and blocked_campaigns.length > 0
      query.where.id = {
        $notIn: blocked_campaigns
      }
    
    
    # Industry Targeting
    industry_where = {
      active: true
    }
    
    if not req.publisher.is_demo
      industry_where.industry_id = req.publisher.industry_id
    
    query.includes.push({
      model: LIBS.models.CampaignIndustry
      as: "industries"
      required: true
      where: industry_where
    })
    
    
    # Publisher NOT Targeting
    query.where["targeting.blocked_publishers"] = {
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
        query.where["targeting.#{target}"] = {
          $or: [
            {
              $eq: null
            }
            {
              $like: "%#{'"' + profile[target] + '"'}%"
            }
          ]
        }
        
    
    # Find Campaigns
    # Grab a random set of 5 campaigns
    # Then we sort the 5 campaigns by bid
    # 70% of the time the highest bid will
    # be shown. 30% of the time the a random
    # creative will be chosen
    order_logic = ["amount", "DESC"]
    
    if Math.random() > 0.7
      order_logic = LIBS.models.Sequelize.fn('RANDOM')
      
    final_query = {
      where: query.where
      include: query.includes
      order: [
        order_logic
        ["updated_at", "ASC"]
      ]
    }
    
    LIBS.models.Campaign.count({
      where: final_query.where
    }).then (count)->
      final_query.offset = Math.floor(Math.random() * count)
    
      LIBS.models.Campaign.findOne(final_query).then (campaign)->    
        if not campaign?
          return Promise.reject LIBS.exchanges.errors.AD_NOT_FOUND
        
        creative = campaign.creatives[0]
        creative.industry_id = campaign.industries[0].id
        return creative
      