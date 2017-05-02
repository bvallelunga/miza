module.exports.get = (req, res, next)->
  LIBS.models.Advertiser.findAll({
    order: [
      ['name', 'ASC']
    ]
    include: [
      {
        model: LIBS.models.Transfer
        as: "transfers"
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
  }).then (advertisers)->  
    res.render "admin/advertisers", {
      js: req.js.renderTags "modal", "admin-table", "fa"
      css: req.css.renderTags "modal", "admin"
      title: "Admin Advertisers"
      advertisers: advertisers
      dashboard: "admin"
    }
    
  .catch next


module.exports.post = (req, res, next)->
  Promise.all req.body.advertisers.map (advertiser)->  
    return LIBS.models.Advertiser.update({
      auto_approve: Number advertiser.auto_approve
    }, {
      returning: false
      individualHooks: true
      where: {
        id: advertiser.id
      }
    })
    
  .then ->
    res.json {
      success: true
      next: "/admin/advertisers"
    }
    
  .catch next
  