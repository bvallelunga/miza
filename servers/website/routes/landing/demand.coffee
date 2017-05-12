module.exports.get_root = (req, res, next)->
  res.render "landing/demand/home", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Enterprise Advertising"
  }


module.exports.get_social = (req, res, next)->
  res.render "landing/demand/social", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Social Self Serve"
  }  


module.exports.get_music = (req, res, next)->
  res.render "landing/demand/music", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Music Self Serve"
  }
  

module.exports.get_commerce = (req, res, next)->
  res.render "landing/demand/commerce", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Commerce Self Serve"
  }
