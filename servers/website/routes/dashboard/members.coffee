module.exports.add = (req, res, next)->
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
        publisher_id: req.publisher.id
      }
    }).then (data)->  
      new_record = data[1]
          
      if not new_record
        return Promise.resolve()
    
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
  LIBS.models.UserAccess.destroy({
    where: {
      id: req.params.invite
    }
  }).then ->
    res.redirect "/dashboard/#{req.publisher.key}/members"
    

module.exports.remove_member = (req, res, next)->
  req.publisher.removeMember(req.params.member).then ->
    res.redirect "/dashboard/#{req.publisher.key}/members"
