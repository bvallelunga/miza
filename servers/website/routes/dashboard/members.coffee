module.exports.add = (req, res, next)->
  if req.user.is_demo or req.user.id == req.publisher.owner.id
    return res.redirect "/dashboard/#{req.publisher.id}/members"

  email = req.body.email.toLowerCase().trim()

  LIBS.models.User.findOne({
    where: {
      email: email
    }
  }).then (user)->
    if user?
      return req.publisher.addMember user
      
    LIBS.models.UserAccess.findOrCreate({
      where: {
        email: email
      }
      defaults: {
        publisher_id: req.publisher.id
      }
    }).then ->
      LIBS.sendgrid.send {
        to: "#{email}"
        subject: "#{req.user.name} invited you to #{req.publisher.name}"
        text: """
        Welcome to Miza!
        
        Miza helps publishers recover ad revenue from ad blockers. #{req.user.name}
        has invited as a member on his #{req.publisher.name} account.
        
        You can register with this link: http://#{req.get("host")}/register?email=#{email}
            
        --
        Miza Support
        """
      }
  
  .then ->
    res.json {
      success: true
      next: "/dashboard/#{req.publisher.key}/members"
    }  
    
  .catch next 


module.exports.remove_invite = (req, res, next)->
  if req.user.is_demo or req.user.id == req.publisher.owner.id
    return res.redirect "/dashboard/#{req.publisher.key}/members"

  LIBS.models.UserAccess.destroy({
    where: {
      id: req.params.invite
    }
    force: true
  }).then ->
    res.redirect "/dashboard/#{req.publisher.key}/members"
    

module.exports.remove_member = (req, res, next)->
  if req.user.is_demo or req.user.id == req.publisher.owner.id
    return res.redirect "/dashboard/#{req.publisher.key}/members"

  req.publisher.removeMember(req.params.member).then ->
    res.redirect "/dashboard/#{req.publisher.key}/members"
