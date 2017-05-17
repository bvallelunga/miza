module.exports.get_root = (req, res, next)->
  res.locals.media.graph = "/imgs/graph/enterprise.png"

  res.render "landing/demand/home", {
    js: req.js.renderTags "landing", "fa"
    css: req.css.renderTags "landing"
    title: "Lets Craft A Story"
    description: "User's love engaging with stories! We'll work directly with your team to create an experience tailored for your brand."
  }


module.exports.get_social = (req, res, next)->
  res.locals.media.graph = "/imgs/graph/social.png"

  res.render "landing/demand/social", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Grow your Twitter and Instagram following"
    description: "Grow your brand through interactive ads that are shown to millions of people daily."
  }  


module.exports.get_music = (req, res, next)->
  res.locals.media.graph = "/imgs/graph/music.png"

  res.render "landing/demand/music", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Grow your SoundCloud following"
    description: "Have millions of people listen to your tracks, albums, and playlists through our ads."
  }
  

module.exports.get_commerce = (req, res, next)->
  res.locals.media.graph = "/imgs/graph/commerce.png"

  res.render "landing/demand/commerce", {
    js: req.js.renderTags "landing", "fa", "modal"
    css: req.css.renderTags "landing"
    title: "Grow your Amazon, Etsy, Kickstarter and Indiegog product awareness"
    description: "Have your Amazon, Etsy, Kickstarter, and Indiegogo products seen by millions daily."
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