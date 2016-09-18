module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    order: [
      ['name', 'ASC']
    ]
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
  }).then (publishers)->
    res.render "admin/publishers", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "admin"
      title: "Admin Publishers"
      publishers: publishers
    }


module.exports.post = (req, res, next)->
  Promise.all req.body.publishers.map (publisher)->
    return LIBS.models.Publisher.update({
      coverate_ratio: Number(publisher.fee) / 100
      fee: Number(publisher.fee) / 100
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
      message: "Publishers have been updated!"
      next: "/admin/publishers"
    }
    
  .catch next
  