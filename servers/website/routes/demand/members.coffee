module.exports.fetch = (req, res, next)->
  req.data.dashboard_width = "medium"
  req.data.js.push "tooltip", "modal"
  req.data.css.push "tooltip"
  
  Promise.props({
    members: req.advertiser.getMembers()
    invites: req.advertiser.getInvites()
  }).then (data)->
    req.data.members = data.members
    req.data.invites = data.invites
    next()
    
  .catch next


module.exports.post_add = (req, res, next)->
  if not req.user.is_admin and req.user.id != req.advertiser.owner_id
    return next "Ownership access is required!"
  
  email = req.body.email.toLowerCase().trim()

  LIBS.models.User.findOne({
    where: {
      email: email
    }
  }).then (user)->
    if user?
      return req.advertiser.addMember user
      
    LIBS.models.UserAccess.findOrCreate({
      where: {
        email: email
        advertiser_id: req.advertiser.id
      }
      defaults: {
        admin_contact_id: req.advertiser.admin_contact_id
      }
    }).then (data)->  
      new_record = data[1]
          
      if not new_record
        return Promise.resolve()
        
      LIBS.emails.send "advertiser_invite", [{
        to: email
        data: {
          user: req.user
          advertiser: req.advertiser
        }
      }]  
  .then ->
    res.json {
      success: true
      next: "/demand/#{req.advertiser.key}/members"
    }  
    
  .catch next 


module.exports.remove_invite = (req, res, next)->
  if not req.user.is_admin and req.user.id != req.advertiser.owner_id
    return res.redirect "/supply/#{req.advertiser.key}/members"

  LIBS.models.UserAccess.destroy({
    where: {
      id: req.params.invite
    }
  }).then ->
    res.redirect "/demand/#{req.advertiser.key}/members"
    
  .catch next 
    

module.exports.remove_member = (req, res, next)->
  if not req.user.is_admin and (req.user.id != req.advertiser.owner_id or req.params.member == req.advertiser.owner_id)
    return res.redirect "/demand/#{req.advertiser.key}/members"
  
  req.advertiser.removeMember(req.params.member).then ->
    res.redirect "/demand/#{req.advertiser.key}/members"
    
  .catch next 
  
  
module.exports.owner_member = (req, res, next)->
  if not req.user.is_admin
    return res.redirect "/demand/#{req.advertiser.key}/members"
  
  req.advertiser.owner_id = req.params.member
  req.advertiser.save().then ->
    res.redirect "/demand/#{req.advertiser.key}/members"
    
  .catch next 

