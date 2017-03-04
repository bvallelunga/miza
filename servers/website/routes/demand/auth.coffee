module.exports = (req, res, next)->
  Promise.resolve().then ->
    return req.user.advertisers.filter (advertiser)->
      return advertiser.key == req.params.advertiser
  
  .then (matches)->
    if matches.length > 0
      return matches[0]
      
    else if req.user.is_admin
      return LIBS.models.Advertiser.findOne({
        where: {
          key: req.params.advertiser
        }
        paranoid: false
      })
      
    return null
  
  .then (advertiser)->
    if not advertiser?
      return res.redirect "/demand"
      
    advertiser.intercom().then (intercom)->
      req.advertiser = advertiser
      res.locals.advertiser = advertiser
      res.locals.intercom.company = intercom
        
      next()
    
  .catch next