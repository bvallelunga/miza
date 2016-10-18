module.exports.get = (req, res, next)->
  LIBS.models.Industry.findAll({
    order: [
      ['name', 'ASC']
    ]
  }).then (industries)->
    res.render "admin/industries", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "modal", "admin", "fa"
      title: "Admin Industries"
      industries: industries
    }
    
  .catch next


module.exports.post = (req, res, next)->
  Promise.all req.body.industries.map (industry)->
    return LIBS.models.Industry.update({
      name: industry.name
      cpm: Number industry.cpm
      private: industry.private == "true"
    }, {
      returning: false
      individualHooks: true
      where: {
        id: industry.id
      }
    })
    
  .then ->
    res.json {
      success: true
      next: "/admin/industries"
    }
    
  .catch next
  