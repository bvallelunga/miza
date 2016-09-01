module.exports.get = (req, res, next)->
  LIBS.models.Industry.findAll({
    order: "name ASC"
  }).then (industries)->
    res.render "dashboard/new", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "fa"
      title: "Create Publisher"
      industries: industries
    }
  
  
module.exports.post = (req, res, next)->
  Publisher = LIBS.models.Publisher 
  
  if not req.body.publisher_industry?
    return next "Please select an industry."

  Publisher.create({
    domain: req.body.publisher_domain
    name: req.body.publisher_name
    industry_id: Number req.body.publisher_industry
  }).then (publisher)->
    publisher.setOwner req.user
    publisher.addNetworks [ 1, 5 ]
    req.user.addPublisher(publisher).then ->
      res.json {
        success: true
        next: "/dashboard/#{publisher.key}/setup"
      }
    
  .catch next