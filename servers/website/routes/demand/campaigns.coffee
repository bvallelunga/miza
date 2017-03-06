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
  LIBS.models.Campaign.update({
    status: req.body.action
  }, {
    individualHooks: true
    where: {
      advertiser_id: req.advertiser.id
      id: {
        $in: req.body.campaigns
      }
    }
  }).then ->
    res.json {
      success: true
    }
  
  .catch next
  
  
module.exports.post_list = (req, res, next)->
  req.advertiser.getCampaigns({
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