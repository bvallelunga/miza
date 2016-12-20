module.exports.get = (req, res, next)->
  LIBS.models.Industry.findAll({
    order: "name ASC"
    where: {
      private: false
    }
  }).then (industries)->
    res.render "dashboard/create", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "fa"
      title: "Create Publisher"
      industries: industries
    }
  
  
module.exports.post = (req, res, next)->
  Publisher = LIBS.models.Publisher 
  industry_id = Number req.body.publisher_industry
    
  if not industry_id
    if req.body.publisher_product == "protect"
      return next "Please select an industry."
    
    else
      industry_id = null

  Publisher.create({
    product: req.body.publisher_product
    domain: req.body.publisher_domain
    name: req.body.publisher_name
    owner_id: req.user.id
    miza_endpoint: req.body.publisher_miza_endpoint == "true"
    industry_id: industry_id
    admin_contact_id: req.user.admin_contact_id
  }).then (publisher)->
    req.user.addPublisher(publisher).then ->
      res.json {
        success: true
        next: "/dashboard/#{publisher.key}/setup?new_publisher"
      }
    
  .catch next