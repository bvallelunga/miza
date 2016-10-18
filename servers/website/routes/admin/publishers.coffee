module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    where: {
      owner_id: {
        $ne: LIBS.models.defaults.github_user.id
      }
    }
    order: [
      ['fee', 'DESC']
      ['name', 'ASC']
    ]
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).then (publishers)->
    res.render "admin/publishers", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "admin", "fa"
      title: "Admin Publishers"
      publishers: publishers
    }
    
  .catch next


module.exports.post = (req, res, next)->
  Promise.all req.body.publishers.map (publisher)->  
    return LIBS.models.Publisher.update({
      coverage_ratio: Number(publisher.coverage) / 100
      fee: Number(publisher.fee) / 100
      miza_endpoint: publisher.miza_endpoint == "true"
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
  