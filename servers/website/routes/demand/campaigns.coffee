module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range")
  req.data.css.push("date-range")
  req.data.dashboard_width = "medium"
  req.data.config = {
    advertiser: req.advertiser.key
  }
  
  Promise.resolve().then ->
    if not req.subdashboard
      req.data.js.push("data-table")
      req.data.css.push("data-table")
      req.subdashboard = "listing"
      
    else if req.subdashboard == "create" 
      req.data.js.push("modal")
      req.subdashboard = "builder"
      
      return LIBS.models.Industry.listed().then (industries)->
        req.data.industries = industries
      
    else
      req.subdashboard = "analytics"
    
  .then(-> next()).catch next
  
  
module.exports.post_updates = (req, res, next)->
  req.advertiser.getOwner().then (owner)->
    if req.body.action == "running" and not owner.stripe_card
      return Promise.reject """
        Please enter in your <a href="/account/billing">billing details</a> to start a campaign.
      """
    
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
      }
    }).each (campaign)->
      campaign.update({
        status: req.body.action
      })
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
  
  
module.exports.post_list = (req, res, next)->
  req.advertiser.getCampaigns({
    where: {
      start_at: {
        $or: [{
          $gte: new Date req.body.dates.start
        }, {
          $eq: null
        }]
      }
      end_at: {
        $or: [{
          $lte: new Date req.body.dates.end
        }, {
          $eq: null
        }]
      }
    }
    include: [{
      model: LIBS.models.CampaignIndustry
      as: "industries"
    }]
  }).then (campaigns)->
    res.json {
      success: true
      results: campaigns
    }
    
  .catch next