module.exports.get_root = (req, res, next)->
  res.render "landing/demand/home", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Lets Craft A Story"
  }


module.exports.get_social = (req, res, next)->
  res.render "landing/demand/social", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Social Self Serve"
  }  


module.exports.get_music = (req, res, next)->
  res.render "landing/demand/music", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Music Self Serve"
  }
  

module.exports.get_commerce = (req, res, next)->
  res.render "landing/demand/commerce", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Commerce Self Serve"
  }


module.exports.post_partnership = (req, res, next)->
  res.render "landing/partnership", {
    title: "Partnership"
    css: req.css.renderTags "modal"
  }
  
  LIBS.intercom.createContact {
    email: req.body.email
  }
  
  LIBS.slack.message {
    text: "#{req.body.name} (#{req.body.email}, #{req.body.phone}) requested a partnership as an enterprise advertiser."
  }