module.exports.utils = utils = require "./utils"
module.exports.auth = require "./auth"

module.exports.check = (req, res, next)->
  res.end req.publisher.key


module.exports.ping = (req, res, next)->
  res.end utils.pixel_tracker
  
  LIBS.ads.event.track req, {
    type: "ping"
  }
  
  LIBS.ads.visitor.track req, {
    device: "desktop"
  }

  
module.exports.impression = (req, res, next)->    
  if req.query.campaign?
    viewed_campaigns = req.signedCookies.viewed_campaigns or {}
    viewed_campaigns[req.query.campaign] = new Date()
    
    res.cookie "viewed_campaigns", viewed_campaigns, { 
      httpOnly: true
      signed: true 
      maxAge: 10000 * 60 * 1000
    }
  
  res.end utils.pixel_tracker
  
  LIBS.ads.event.track req, {
    type: "impression"
  }
  

module.exports.click = (req, res, next)->
  if req.query.next 
    url = new Buffer(req.query.next, 'base64').toString("ascii")
    res.redirect url
  
  else
    res.end utils.pixel_tracker
  
  LIBS.ads.event.track req, {
    type: "click"
  }
