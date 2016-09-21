module.exports.get = (req, res, next)->
  res.render "auth/login", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Sign In"
  }
  

module.exports.post = (req, res, next)->  
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
    next_path = "/dashboard"
    
    if user.is_admin
      next_path = "/admin"
    
    res.json {
      success: true
      next: next_path
    }
    
  .catch next
    