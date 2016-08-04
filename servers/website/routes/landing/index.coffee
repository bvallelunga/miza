module.exports.get_root = (req, res, next)-> 
  res.render "landing/index", {
    js: req.js.renderTags "landing", "code"
    css: req.css.renderTags "landing", "code"
  }


module.exports.post_beta = (req, res, next)->
  res.render "landing/access_requested", {
    css: req.css.renderTags "modal"
    intercom: {
      email: req.body.email
      access_requested: true
      access_requested_at: new Date()
    }
  }
  

module.exports.get_not_found = (req, res, next)->
  res.redirect "/"
  