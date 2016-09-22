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
