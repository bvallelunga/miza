module.exports.get_root = (req, res, next)->
  LIBS.models.Notice.findAll({
    order: [
      ['created_at', 'DESC']
    ]
  }).then (notices)->
    res.render "admin/notices", {
      js: req.js.renderTags "modal", "fa", "admin-notices", "date-range"
      css: req.css.renderTags "modal", "admin", "date-range"
      title: "Admin Notices"
      notices: notices
      dashboard: "admin"
    }
    
  .catch next

    
module.exports.get_delete = (req, res, next)->
  LIBS.models.Notice.destroy({
    where: {
      id: req.params.notice
    }
  }).then (payout)->
    res.redirect "/admin/notices"
  
  .catch next


module.exports.post_create = (req, res, next)->
  LIBS.models.Notice.create({
    message: req.body.message
    target: req.body.target
    start_at: new Date req.body.start_at
    end_at: new Date req.body.end_at
    owner_id: req.user.id
  }).then (payout)->
    res.json {
      success: true
      next: "/admin/notices"
    }
  
  .catch next
