module.exports.get = (req, res, next)->
  LIBS.models.User.findAll({
    order: [
      ['stripe_card', 'ASC']
      ['name', 'ASC']
    ]
    include: [{
      model: LIBS.models.User
      as: "admin_contact"
    }]
  }).then (users)->
    res.render "admin/users", {
      js: req.js.renderTags "modal", "admin-table", "fa"
      css: req.css.renderTags "modal", "admin"
      title: "Admin Users"
      users: users
      dashboard: "admin"
    }
    
  .catch next


module.exports.simulate = (req, res, next)->
  LIBS.models.User.findById(req.params.user).then (user)->
    if user.is_admin
      return Promise.reject "Can not simualte on admin account!"
    
    req.session.user = user.id
    req.session.simulate = true
    res.redirect "/dashboard"
    
  .catch next