module.exports.post = (req, res, next)->
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
      next: req.body.next or "/account/password"
    }
  
  .catch next