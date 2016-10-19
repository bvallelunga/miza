module.exports.get_root = (req, res, next)->
  res.render "account/index", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal", "fa"
    title: "Account Settings"
  }


module.exports.post_root = (req, res, next)->
  temp_password = LIBS.models.User.hash req.body.password
  
  if req.user.password != temp_password
    return next "Invaild password"
    
  req.user.notifications.weekly_reports = req.body.weekly_reports == "true"

  req.user.update({
    name: req.body.name
    email: req.body.email
    notifications: req.user.notifications 
  }).then ->
    res.json {
      success: true
      next: "/account"
    }
  
  .catch next
  
  
module.exports.get_password = (req, res, next)->
  res.render "account/password", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Update Password"
  }

  
module.exports.post_password = (req, res, next)->
  temp_password = LIBS.models.User.hash req.body.old_password
  
  if req.user.password != temp_password
    return next "Invaild old password"
    
  if req.body.new_password != req.body.confirm_password
    return next "Passwords do not match"

  req.user.update({
    password: req.body.new_password
  }).then ->
    res.json {
      success: true
      message: "Your password has been updated!"
      next: "/account"
    }
  
  .catch next
  

module.exports.get_card = (req, res, next)->
  res.render "account/card", {
    js: req.js.renderTags "card"
    css: req.css.renderTags "modal"
    title: "Save Card"
    config: {
      stripe_key: CONFIG.stripe.public
    }
  }

  
module.exports.post_card = (req, res, next)->
  req.user.stripe_set_card(req.body).then ->
    res.json {
      success: true
      message: "Your card has been added!"
      next: "/account"
    }
  
  .catch next
  
  
  