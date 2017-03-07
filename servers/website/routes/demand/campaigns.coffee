module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range")
  req.data.css.push("date-range")
  req.data.dashboard_width = "medium"
  req.data.config = {
    advertiser: req.advertiser.key
  }
  
  if not req.subdashboard
    req.data.js.push("data-table")
    req.data.css.push("data-table")
    req.subdashboard = "listing"
    next()
    
  else if req.subdashboard == "create" 
    req.data.js.push("modal")
    req.subdashboard = "builder"
    
    LIBS.models.Industry.listed().then (industries)->
      req.data.industries = industries
      next()
    
    .catch next
    
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
    order: [
      ['name', 'ASC']
    ]
  }).then (campaigns)->
    res.json {
      success: true
      results: campaigns
    }
    
  .catch next