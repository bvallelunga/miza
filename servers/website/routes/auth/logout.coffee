module.exports.get = (req, res, next)->
  req.session.destroy()
  res.redirect req.query.next or "/"