module.exports.get = (req, res, next)->
  Promise.props({
    industries: LIBS.models.Industry.findAll()
    publishers: LIBS.models.Publisher.findAll({
      order: [
        ['is_activated', 'DESC']
        ['name', 'ASC']
      ]
      include: [
        {
          model: LIBS.models.Industry
          as: "industry"
        }
        {
          model: LIBS.models.User
          as: "admin_contact"
        }
        {
          model: LIBS.models.User
          as: "owner"
        }
      ]
    })
  }).then (props)->  
    res.render "admin/publishers", {
      js: req.js.renderTags "modal", "admin-table", "fa"
      css: req.css.renderTags "modal", "admin"
      title: "Admin Publishers"
      publishers: props.publishers
      industries: props.industries
      dashboard: "admin"
    }
    
  .catch next


module.exports.post = (req, res, next)->
  Promise.all req.body.publishers.map (publisher)->  
    return LIBS.models.Publisher.update({
      fee: 1 - (Number(publisher.fee) / 100)
      miza_endpoint: publisher.miza_endpoint == "true"
      industry_id: publisher.industry
    }, {
      returning: false
      individualHooks: true
      where: {
        id: publisher.id
      }
    })
    
  .then ->
    res.json {
      success: true
      next: "/admin/publishers"
    }
    
  .catch next
  