module.exports.post = (req, res, next)->
  req.user.update({
    paypal: req.body.paypal
  }).then ->
    res.json {
      success: true
      message: "Your payout information has been updated!"
      next: req.body.next or "/account/profile"
    }
  
  .catch next