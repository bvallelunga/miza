module.exports.login = require "./login"
module.exports.register = require "./register"
module.exports.logout = require "./logout"
module.exports.forgot = require "./forgot"


module.exports.load_user = (req, res, next)->
  if not req.session.user?
    return next()

  LIBS.models.User.findById(req.session.user, {
    include: [{
      model: LIBS.models.Publisher
      as: "publishers"
    }, {
      model: LIBS.models.Advertiser
      as: "advertisers"
    }]
  }).then (user)->
    req.user = user
    next()

  .catch next


module.exports.not_authenticated = (req, res, next)->
  if not req.user?
    return next()

  if req.user.is_demo
    return res.redirect "/logout"

  if req.user.is_admin
    return res.redirect "/admin"

  res.redirect "/dashboard"


module.exports.is_authenticated = (req, res, next)->
  if not req.user?
    return res.redirect "/login?next=#{req.originalUrl}"

  # if req.useragent.isMobile
  #   return res.redirect "/m#{req.originalUrl}"

  # if req.useragent.isMobile and not req.user.is_admin
  #   return res.redirect "/mobile"

  next()


module.exports.is_admin = (req, res, next)->
  if not req.user? or not req.user.is_admin
    return req._routes.landing.get_not_found(req, res)

  next()
