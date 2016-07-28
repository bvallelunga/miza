module.exports.get_login = (req, res, next)->
  res.render "auth/index", {
    js: req.js.renderTags "auth"
    css: req.css.renderTags "auth"
    title: "Log In"
  }
  

module.exports.get_logout = (req, res, next)->
  res.redirect "/"
  
  
module.exports.post_login = (req, res, next)->
  res.json {
    success: true
    next: "/dashboard"
  }