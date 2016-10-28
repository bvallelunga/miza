module.exports.get = (req, res, next)->
  res.render "auth/register", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Sign Up"
    name: req.query.name or ""
    email: req.query.email or ""
  }
  
  
module.exports.post = (req, res, next)-> 
  email = req.body.email.toLowerCase().trim()
  
  if req.body.password != req.body.confirm_password
    return next "Passwords do not match"
 
  LIBS.models.UserAccess.findAll({
    where: {
      email: email
    }
  }).then (accesses)->  
    if accesses.length == 0
      return next "Email address not approved for beta."
  
    admin_contact = null
    admin_contacts = accesses.filter (access)->
      return access.admin_contact_id?  
    
    if admin_contacts.length > 0
      admin_contact = admin_contacts[0].admin_contact_id
    
    LIBS.models.User.create({
      email: email
      password: req.body.password
      name: req.body.name
      phone: req.body.phone or null
      admin_contact_id: admin_contact
      is_admin: (accesses.filter (access)->
        return access.is_admin
      .length > 0) 
    }).then (user)->
      req.session.user = user.id
      
      Promise.filter accesses, (access)->
        return access.publisher_id?
        
      .then (accesses)->
        Promise.map accesses, (access)->
          return access.publisher_id
          
      .then (publisher_ids)-> 
        return user.addPublishers publisher_ids
        
      .then ->
        LIBS.models.UserAccess.destroy {
          where: {
            id: {
              $in: accesses.map (access)->
                return access.id
            }
          }
        }
      
    .then ->
      res.json {
        success: true
        next: "/dashboard"
      }
      
  .catch next