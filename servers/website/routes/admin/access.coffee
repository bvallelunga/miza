module.exports.get = (req, res, next)->
  LIBS.models.UserAccess.findAll({
    order: [
      ['created_at', 'DESC']
    ]
    include: [
      {
        model: LIBS.models.Publisher
        as: "publisher"
      }
      {
        model: LIBS.models.User
        as: "admin_contact"
      }
    ]
  }).then (invites)->
    res.render "admin/access", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "admin"
      title: "Admin Grant Access"
      invites: invites
    }


module.exports.post = (req, res, next)->
  emails = req.body.emails.toLowerCase().split("\n")

  LIBS.models.UserAccess.bulkCreate(emails.map (email)->
    return { 
      email: email.trim() 
      admin_contact_id: req.user.id
    }
  , {
    returning: false
    individualHooks: true
  }).then ->
    res.json {
      success: true
      message: "Users have been approved for registration!"
      next: "/admin"
    }
    
  .catch next


module.exports.remove = (req, res, next)->
  LIBS.models.UserAccess.destroy({
    where: {
      id: req.params.invite
    }
  }).then ->
    res.redirect "/admin/access"
    
  .catch next
