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
        
      LIBS.emails.send "publisher_invite", [{
        to: email
        host: req.get("host")
        data: {
          user: req.user
          publisher: req.publisher
        }
      }]  
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
