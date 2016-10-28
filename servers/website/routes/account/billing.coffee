module.exports.post = (req, res, next)->
  req.user.stripe_set_card(req.body).then ->
    res.json {
      success: true
      message: "Your card has been added!"
      next: "/account/profile"
    }
  
  .catch next