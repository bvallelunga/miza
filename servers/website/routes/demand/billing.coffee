module.exports.fetch = (req, res, next)->  
  if req.subdashboard
    return res.redirect "/dashboard/demand/#{req.advertiser.key}/billing"
  
  req.data.js.push "tooltip"
  req.data.css.push "tooltip"
  
  Promise.resolve().then ->
    req.advertiser.getTransfers({
      order: [
        ["created_at", "DESC"]
      ]
    }).then (transfers)->
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
  
  

module.exports.post_charges = (req, res, next)->
  req.advertiser.approve_spending().then ->
    res.json({
      sucess: true
    })
  
  .catch next