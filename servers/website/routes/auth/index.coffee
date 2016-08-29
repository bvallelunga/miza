module.exports.get_login = (req, res, next)->
  res.render "auth/login", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Sign In"
  }
  

module.exports.get_register = (req, res, next)->
  res.render "auth/register", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Sign Up"
    name: req.query.name or ""
    email: req.query.email or ""
  }
  

module.exports.get_logout = (req, res, next)->
  req.session.destroy()
  res.redirect req.query.next or "/"
  
  
module.exports.post_login = (req, res, next)->  
  LIBS.models.User.findOne({
    where: {
      email: req.body.email.toLowerCase().trim()
      password: LIBS.models.User.hash req.body.password
    }
  }).then (user)->
    if not user?
      return res.status(400).json {
        success: false
        message: "Invalid credentials"
        csrf: req.csrfToken()
      }
    
    req.session.user = user.id
    
    res.json {
      success: true
      next: "/dashboard"
    }
    
  .catch next
    
    
module.exports.post_register = (req, res, next)-> 
  email = req.body.email.toLowerCase().trim()
  
  if req.body.password != req.body.confirm_password
    return next "Passwords do not match"
 
  LIBS.models.UserAccess.findOne({
    where: {
      email: email
    }
  }).then (access)->  
    if not access?
      return res.status(400).json {
        success: false
        message: "Email address not approved for beta."
        csrf: req.csrfToken()
      }
  
    LIBS.models.User.create({
      email: email
      password: req.body.password
      name: req.body.name
      is_admin: access.is_admin
    }).then (user)->
      req.session.user = user.id
    
      if not access.publisher_id
        return user
          
      return user.addPublisher access.publisher_id
      
    .then ->
      res.json {
        success: true
        next: "/dashboard"
      }
      
  .catch next


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
    return res.redirect "/logout?next=#{req.originalUrl}"
    
  res.redirect "/dashboard"


module.exports.is_authenticated = (req, res, next)->
  if not req.user?
    return res.redirect "/"
    
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
    
    req.publisher = publisher
    res.locals.publisher = publisher
    
    if not publisher.is_demo
      res.locals.intercom.company = {
        id: publisher.id
        name: publisher.name
      }
    
    next()
    
  .catch (error)->
    res.redirect "/dashboard"
  