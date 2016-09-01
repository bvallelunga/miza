module.exports.get = (req, res, next)->
  LIBS.models.Industry.findAll({
    order: [
      ['name', 'ASC']
    ]
  }).then (industries)->
    res.render "admin/industries", {
      js: req.js.renderTags "modal"
      css: req.css.renderTags "admin", "fa"
      title: "Admin Industries"
      industries: industries
    }


module.exports.post = (req, res, next)->
  Promise.all req.body.industries.map (industry)->
    return LIBS.models.Industry.update({
      name: industry.name
      cpm: Number industry.cpm
      cpc: Number industry.cpc
      fee: Number(industry.fee)/100
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
      message: "Industries have been updated!"
      next: "/admin"
    }
    
  .catch next
  