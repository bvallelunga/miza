module.exports.get = (req, res, next)->
  if req.publisher.product != "protect"
    return res.redirect "/publisher/#{req.publisher.key}/analytics"

  res.render "publisher/migrate", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "publisher", "fa", "landing"
    title: "Migration Dashboard"
  }
  
  
module.exports.post = (req, res, next)->
  req.publisher.update({
    product: "network"
  }).then ->
    res.json {
      success: true
      next: "/publisher/#{req.publisher.key}/setup?new_publisher"
    }
    
  .catch next