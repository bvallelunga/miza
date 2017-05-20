module.exports.fetch = (req, res, next)->  
  LIBS.models.Campaign.findOne({
    where: {
      id: req.subdashboard or req.params.campaign
      advertiser_id: req.advertiser.id
    }
    include: [{
      model: LIBS.models.Creative
      as: "creatives"
    }]
  }).then (campaign)->
    if not campaign?
      return res.redirect "/dashboard/demand/#{req.advertiser.key}/campaigns"
    
    req.advertiser.credits = 0
    req.data.subdashboard = ""
    req.data.campaign = campaign
    req.data.dashboard_width = ""
    req.data.js.push "dashboard", "card", "fa"
    req.data.next = req.query.next or "/dashboard/demand/#{req.advertiser.key}/campaign/#{campaign.id}"
    res.locals.config.next = req.query.next or "/dashboard/demand/#{req.advertiser.key}/campaign/#{campaign.id}"
    res.locals.config.stripe_key = CONFIG.stripe.public
    next()
    

module.exports.post_add = (req, res, next)-> 
  LIBS.models.Campaign.findOne({
    where: {
      id: req.params.campaign
      advertiser_id: req.advertiser.id
    }
  }).then (campaign)->
    if not campaign?
      return next "Invalid campaign type"
      
    campaign.credits = Math.min campaign.budget, 50
    campaign.save()
    
  .then ->
    req._routes.account.billing.post(req, res, next)