module.exports.fetch = (req, res, next)->
  req.data.js.push("modal")

  req.advertiser.getOwner().then (owner)->
    req.advertiser.owner = owner
    next()
    
  .catch next
  

module.exports.post_update = (req, res, next)->
  req.advertiser.name = req.body.name
  req.advertiser.domain = req.body.domain or null
  
  if req.user.is_admin
    req.advertiser.credits = Number req.body.credits
  
  req.advertiser.save().then ->
    res.json({
      success: true
      next: req.path
    })
    
  .catch next