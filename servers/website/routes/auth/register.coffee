module.exports.get = (req, res, next)->
  res.render "auth/register", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Sign Up"
    name: req.query.name or ""
    email: req.query.email or ""
  }
  
  
module.exports.post = (req, res, next)-> 
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