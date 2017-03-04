module.exports = (req, res, next)->
  Promise.resolve().then ->
    return req.user.publishers.filter (publisher)->
      return publisher.key == req.params.publisher
  
  .then (matches)->
    if matches.length > 0
      return matches[0]
      
    else if req.user.is_admin
      return LIBS.models.Publisher.findOne({
        where: {
          key: req.params.publisher
        }
        paranoid: false
      })
      
    return null
  
  .then (publisher)->
    if not publisher?
      return res.redirect "/supply"
      
    publisher.associations({
      owner: true
      industry: true
    }).then ->
      publisher.intercom()
  
    .then (intercom)->
      req.publisher = publisher
      res.locals.publisher = publisher
      res.locals.intercom.company = intercom
        
      next()
    
  .catch next