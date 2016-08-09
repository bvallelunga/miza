module.exports.get_root = (req, res, next)->
  res.render "admin/index", {
    css: req.css.renderTags "admin", "fa"
    title: "Admin Center"
  }
  

module.exports.get_access = (req, res, next)->
  res.render "admin/access", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    title: "Grant Access"
  }


module.exports.post_access = (req, res, next)->
  emails = req.body.emails.toLowerCase().split("\n")

  LIBS.models.UserAccess.bulkCreate(emails.map (email)->
    return { 
      email: email.trim() 
    }
  ).then ->
    res.json {
      success: true
      message: "Users have been approved for registration!"
      next: "/admin"
    }
    
  .catch next
  
  
module.exports.get_industries = (req, res, next)->
  LIBS.models.Industry.findAll().then (industries)->
    res.render "admin/industries", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "fa"
      title: "Update Industries"
      industries: industries
    }


module.exports.post_industries = (req, res, next)->
  console.log req.body

  Promise.all req.body.industries.map (industry)->
    return LIBS.models.Industry.update({
      name: industry.name
      cpm: Number industry.cpm
      cpc: Number industry.cpc
      fee: Number industry.fee
    }, {
      where: {
        id: industry.id
      }
    })
    
  .then ->
    res.json {
      success: true
      message: "Industries have been updated!"
      next: "/admin/industries"
    }
    
  .catch next
  