moment = require "moment"

module.exports.get = (req, res, next)->
  LIBS.models.Shortener.findAll({
    where: {
      created_at: {
        $gte: moment().subtract(1, "month").toDate()
      }
    }
    order: [
      ["created_at", "DESC"]
    ]
    include: [{
      model: LIBS.models.User
      as: "owner"
    }]
  }).then (shorteners)->
    res.render "admin/demo", {
      js: req.js.renderTags "modal", "fa", "demand"
      css: req.css.renderTags "dashboard", "admin"
      title: "Admin Demos"
      shorteners: shorteners
      dashboard: "admin"
    } 
    
  .catch next

 
module.exports.post = (req, res, next)->  
  if not req.body.creative.image_url.length > 0
    return next "Please make sure you have uploaded an image for your creative."
    
  if not req.body.creative.link.length > 0
    return next "Please make sure you have a click link for your creative."

  LIBS.models.Creative.fetch_image(req.body.creative.image_url).then (image)->
    LIBS.models.Creative.create({
      link: req.body.creative.link
      description: req.body.creative.description
      format: "300 x 250"
      image: image
    })
  
  .then (creative)->
    LIBS.models.Shortener.create({
      name: req.body.name
      url: req.body.url
      creative_id: creative.id
      owner_id: req.user.id
    })
  
  .then ->
    res.json {
      success: true
      next: "/admin/demo"
    }
  
  .catch next