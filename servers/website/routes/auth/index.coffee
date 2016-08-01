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
  }
 
 
module.exports.get_user_access = (req, res, next)->
  res.render "auth/user_access", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Invite Users"
  }
  

module.exports.get_logout = (req, res, next)->
  req.session.destroy()
  res.redirect "/"
  
  
module.exports.post_login = (req, res, next)->  
  LIBS.models.User.findOne({
    where: {
      email: req.body.email
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
  LIBS.models.UserAccess.count({
    where: {
      email: req.body.email 
    }
  }).then (count)->
    if count == 0
      return res.status(400).json {
        success: false
        message: "Email address not approved for beta."
        csrf: req.csrfToken()
      }
  
    LIBS.models.User.create({
      email: req.body.email
      password: req.body.password
      name: req.body.name
    }).then (user)->
      req.session.user = user.id
      
      res.json {
        success: true
        next: "/dashboard"
      }
      
  .catch next


module.exports.post_user_access = (req, res, next)->
  emails = req.body.emails.split("\n")

  LIBS.models.UserAccess.bulkCreate(emails.map (email)->
    return { email: email }
  ).then ->
    res.json {
      success: true
      message: "Users have been approved for registration!"
      next: "/user/access"
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
  if req.user?
    return res.redirect "/"
    
  next()


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
      
    else if not req.user.is_admin
      return null
      

    return LIBS.models.Publisher.findOne({
      where: {
        key: req.params.publisher
      }
    })
  
  .then (publisher)->
    if not publisher?
      return res.redirect "/dashboard"
    
    req.publisher = publisher
    next()
  