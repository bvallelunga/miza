module.exports.post = (req, res, next)->
  req.user.notifications.weekly_reports = req.body.weekly_reports == "true"

  req.user.update({
    notifications: req.user.notifications 
  }).then ->
    res.json {
      success: true
      next: "/account/notifications"
    }
  
  .catch next