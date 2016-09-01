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
      css: req.css.renderTags "admin"
      title: "Admin Publishers"
      publishers: publishers
    }
