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
  if not req.body.publisher_industry
    return next "Please select an industry."
      
  if not req.body.dns
    return next "Please select a DNS option."
    
  if not req.body.cloudflare
    return next "Please select a Cloudflare option."
    
  if not req.body.ssl
    return next "Please select a SSL option."

  miza_endpoint = req.body.dns != "true"
  
  if req.body.dns == "true" and req.body.ssl == "true"
    miza_endpoint = req.body.cloudflare != "true"

  LIBS.models.Publisher.create({
    product: "network"
    domain: req.body.publisher_domain
    name: req.body.publisher_name
    owner_id: req.user.id
    miza_endpoint: miza_endpoint
    industry_id: Number req.body.publisher_industry
    admin_contact_id: req.user.admin_contact_id
  }).then (publisher)->
    req.user.addPublisher(publisher).then ->
      res.json {
        success: true
        next: "/supply/#{publisher.key}/setup?new_publisher"
      }
    
  .catch next