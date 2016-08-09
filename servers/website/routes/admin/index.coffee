module.exports.get_root = (req, res, next)->
  res.render "admin/index", {
    css: req.css.renderTags "admin", "fa"
    title: "Admin Center"
  }
  

module.exports.get_access = (req, res, next)->
  res.render "admin/access", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Grant Access"
  }


module.exports.post_access = (req, res, next)->
  emails = req.body.emails.toLowerCase().split("\n")

  LIBS.models.UserAccess.bulkCreate(emails.map (email)->
    return { 
      email: email.trim() 
    }
  ).then ->
    res.json {
      success: true
      message: "Users have been approved for registration!"
      next: "/user/access"
    }
    
  .catch next