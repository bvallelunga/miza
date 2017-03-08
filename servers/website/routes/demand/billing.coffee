module.exports.fetch = (req, res, next)->  
  if req.subdashboard
    return res.redirect "/demand/#{req.advertiser.key}/billing"
  
  req.data.js.push "tooltip"
  req.data.css.push "tooltip"
  
  Promise.resolve().then ->
    req.advertiser.getTransfers().then (transfers)->
      req.advertiser.transfers = transfers
    
  .then ->
    req.advertiser.getCampaigns({
      where: {
        status: {
          $ne: "completed"
        }
      }
      include: [{
        model: LIBS.models.CampaignIndustry
        as: "industries"
      }]
    }).then (campaigns)->
      req.advertiser.campaigns = campaigns
  
  .then(-> next()).catch next