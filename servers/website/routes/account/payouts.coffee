module.exports.post = (req, res, next)->
  req.user.stripe_payout_card(req.body).then ->
    res.json {
      success: true
      message: "Your payout information has been updated!"
      next: "/account/profile"
    }
  
  .catch next