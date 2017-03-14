module.exports.get = (req, res, next)->
  LIBS.models.Industry.findAll({
    order: "name ASC"
    where: {
      private: false
    }
  }).then (industries)->
    res.render "supply/create", {
      js: req.js.renderTags "modal", "fa"
      css: req.css.renderTags "modal"
      title: "Create Publisher"
      industries: industries
    }
  
  
module.exports.post = (req, res, next)->
  Publisher = LIBS.models.Publisher 
  industry_id = null
    
  if req.body.publisher_product == "protect"
    if req.body.publisher_industry
      industry_id = Number req.body.publisher_industry
    
    else
      return next "Please select an industry."
      
  if not req.body.publisher_miza_endpoint
    return next "Please select a DNS option."

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
        next: "/supply/#{publisher.key}/setup?new_publisher"
      }
    
  .catch next