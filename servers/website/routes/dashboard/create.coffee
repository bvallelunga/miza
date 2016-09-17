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
  
  if not req.body.publisher_industry?
    return next "Please select an industry."

  Promise.props({
    publisher: Publisher.create({
      domain: req.body.publisher_domain
      name: req.body.publisher_name
      industry_id: Number req.body.publisher_industry
    })
    networks: LIBS.models.Network.findAll({
      include: [ "id" ]
    })
  }).then (props)->
    props.publisher.setOwner req.user
    props.publisher.addNetworks props.networks
    req.user.addPublisher(props.publisher).then ->
      res.json {
        success: true
        next: "/dashboard/#{props.publisher.key}/setup?new_publisher"
      }
    
  .catch next