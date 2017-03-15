randomstring = require "randomstring"

module.exports.get = (req, res, next)->
  res.render "auth/forgot", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Forgot Password"
  }
  
  
module.exports.post = (req, res, next)->
  LIBS.models.User.findOne({
    where: {
      email: req.body.email.toLowerCase().trim()
    }
  }).then (user)->  
    if not user?
      return next "Email address not found"
      
    random = randomstring.generate({
      length: 5
      charset: 'alphabetic'
    })
    
    LIBS.redis.set "user.reset.#{random}", user.id
    LIBS.emails.send "forgot_password", [{
      to: user.email
      host: req.get("host")
      data: {
        user: user
        random: random
      }
    }]
    
  .then (response)->  
    res.json {
      success: true
      message: "An email has been sent with a reset link!"
      next: "/forgot"
    }
    
  .catch next

  

module.exports.reset_get = (req, res, next)->
  res.render "auth/reset", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Reset Password"
  }
  
  
module.exports.reset_post = (req, res, next)->
  redis_key = "user.reset.#{req.params.key}"

  LIBS.redis.get redis_key, (error, user_id)->   
    if error? or not user_id?
      return "Invalid reset key."
      
    if req.body.new_password != req.body.confirm_password
      return next "Passwords do not match"
    
    LIBS.models.User.update({
      password: req.body.new_password
    }, {
      where: {
        id: user_id
      }
    }).then ->
      LIBS.redis.del redis_key
      req.session.user = user_id

      res.json {
        success: true
        message: "Your password has been updated!"
        next: "/dashboard"
      }
      
    .catch next
    
    
    
  
