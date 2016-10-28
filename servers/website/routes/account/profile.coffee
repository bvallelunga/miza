module.exports.post = (req, res, next)->
  req.user.update({
    name: req.body.name
    email: req.body.email
    phone: req.body.phone or null
  }).then ->
    res.json {
      success: true
      next: "/account/profile"
    }
  
  .catch next