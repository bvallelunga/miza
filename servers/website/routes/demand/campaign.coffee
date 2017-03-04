module.exports.post_create = (req, res, next)->
  res.json({
    success: true
    next: "/demand/#{req.advertiser.key}/campaigns/#{1}"
  })