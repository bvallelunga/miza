module.exports.get = (req, res, next)->
  res.render "auth/register", {
    js: req.js.renderTags "modal", "fa"
    css: req.css.renderTags "modal"
    title: "Sign Up"
    name: req.query.name or ""
    email: req.query.email or ""
  }
  
  
module.exports.post = (req, res, next)-> 
  email = req.body.email.toLowerCase().trim()
  
  if not req.body.type?
    return next "Please select your user type."
 
  LIBS.models.UserAccess.findAll({
    where: {
      email: email
    }
  }).then (accesses)-> 
    if accesses.length == 0
      return next "Sorry, Miza is invite only at this point. Please reach out to our team for an invite!"
  
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
      type: req.body.type
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
      if accesses.length > 0
        req.session.new_publisher = true    
      
      res.json {
        success: true
        next: "/dashboard"
      }
      
  .catch next