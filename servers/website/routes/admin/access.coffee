module.exports.get = (req, res, next)->
  res.render "admin/access", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Admin Grant Access"
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
