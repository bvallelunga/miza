module.exports.get = (req, res, next)->
  if req.user.advertisers.length > 0 and not req.user.is_admin
    return res.redirect "/dashboard/demand"

  res.render "demand/create", {
    js: req.js.renderTags "modal", "fa"
    css: req.css.renderTags "modal"
    title: "Create Advertiser"
  }
  
  
module.exports.post = (req, res, next)->
  LIBS.models.Advertiser.create({
    domain: req.body.domain
    name: req.body.name
    owner_id: req.user.id
    admin_contact_id: req.user.admin_contact_id
  }).then (advertiser)->
    req.user.addAdvertiser(advertiser).then ->
      res.json {
        success: true
        next: "/dashboard/demand/#{advertiser.key}/campaigns?new_advertiser"
      }
    
  .catch next