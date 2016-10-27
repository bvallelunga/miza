module.exports.login = require "./login"
module.exports.register = require "./register"
module.exports.logout = require "./logout"
module.exports.forgot = require "./forgot"
module.exports.invite = require "./invite"


module.exports.load_user = (req, res, next)->
  if not req.session.user?
    return next()
  
  LIBS.models.User.findById(req.session.user, {
    include: [{
      model: LIBS.models.Publisher
      as: "publishers"
    }]
  }).then (user)->
    req.user = user
    next()
    
  .catch next
     

module.exports.not_authenticated = (req, res, next)->
  if not req.user?
    return next()
    
  if req.user.is_demo
    return res.redirect "/logout"
  
  if req.user.is_admin
    return res.redirect "/admin"
  
  res.redirect "/dashboard"


module.exports.is_authenticated = (req, res, next)->
  if not req.user?
    return res.redirect "/login?next=#{req.originalUrl}"
    
  next()

    
module.exports.is_admin = (req, res, next)->
  if not req.user? or not req.user.is_admin
    return res.redirect "/"
  
  next()
    

module.exports.has_publisher = (req, res, next)->
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
      })
      
    return null
  
  .then (publisher)->
    if not publisher?
      return res.redirect "/dashboard"
      
    publisher.associations({
      owner: true
      industry: true
    }).then ->
      publisher.intercom().then (intercom)->
        req.publisher = publisher
        res.locals.publisher = publisher
        res.locals.intercom.company = intercom
          
        next()
    
  .catch next
  