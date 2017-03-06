module.exports.fetch = (req, res, next)->
  req.data.js.push("modal")

  req.advertiser.getOwner().then (owner)->
    req.advertiser.owner = owner
    next()
    
  .catch next
  

module.exports.post_update = (req, res, next)->
  req.advertiser.update({
    name: req.body.name
    domain: req.body.domain or null
  }).then ->
    res.json({
      success: true
      next: req.path
    })
    
  .catch next