module.exports.get_root = (req, res, next)-> 
  res.render "landing/index", {
    js: req.js.renderTags "landing", "code"
    css: req.css.renderTags "landing", "code"
  }


module.exports.post_beta = (req, res, next)->
  res.render "landing/beta", {
    js: req.js.renderTags "auth"
    css: req.css.renderTags "auth"
    intercom: {
      email: req.body.email
      beta: true
      beta_at: new Date()
    }
  }