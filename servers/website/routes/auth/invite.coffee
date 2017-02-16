module.exports.fetch = (req, res, next)->
  LIBS.models.PublisherInvite.findOne({
    where: {
      key: req.params.key
    }
    include: [{
      model: LIBS.models.Publisher
      as: "publisher"
    }]
  }).then (invite)->
    if not invite?
      return res.redirect "/"
      
    req.invite = invite
    next()


module.exports.get = (req, res, next)->
  res.render "auth/invite", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "#{LIBS.helpers.capitalize req.invite.source} Invite"
    invite: req.invite
  }
  

module.exports.post = (req, res, next)->
  email = req.body.email.toLowerCase().trim()
  
  LIBS.models.User.create({
    email: email
    password: req.body.password
    name: req.body.name
  }).then (user)->
    req.session.user = user.id
  
    req.invite.publisher.update({
      owner_id: user.id
    }).then ->
      user.addPublisher req.invite.publisher
      
  .then ->
    req.invite.destroy()
      
  .then ->
    res.json {
      success: true
      next: "/#{user.type}"
    }