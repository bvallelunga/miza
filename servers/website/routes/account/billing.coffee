module.exports.post = (req, res, next)->
  req.user.stripe_billing_card(req.body).then ->
    res.json {
      success: true
      message: "Your card has been added!"
      next: "/account/profile"
    }
  
  .catch next