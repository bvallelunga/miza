module.exports.get = (req, res, next)->
  LIBS.models.User.findAll({
    order: [
      ['stripe_card', 'ASC']
      ['name', 'ASC']
    ]
  }).then (users)->
    res.render "admin/users", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "admin", "fa"
      title: "Admin Users"
      users: users
    }
    
  .catch next


module.exports.post = (req, res, next)->
  Promise.all req.body.users.map (user)->
    return LIBS.models.User.update({
      is_admin: user.is_admin == "true"
    }, {
      returning: false
      individualHooks: true
      where: {
        id: user.id
      }
    })
    
  .then ->
    res.json {
      success: true
      message: "Users have been updated!"
      next: "/admin/users"
    }
    
  .catch next
  