utils = require "./utils"

module.exports.auth = require "./auth"

module.exports.check = (req, res, next)->
  res.end req.publisher.key


module.exports.ping = (req, res, next)->
  res.end utils.pixel_tracker
  
  LIBS.ads.track req, {
    type: "ping"
    publisher: req.publisher
  }

  
module.exports.impression = (req, res, next)->
  res.end utils.pixel_tracker
  
  LIBS.ads.track req, {
    type: "impression"
    publisher: req.publisher
  }


module.exports.click = (req, res, next)->
  encoded = utils.decoder req.params[0]
  url = new Buffer(encoded, 'base64').toString("ascii")
  
  res.redirect url
  
  LIBS.ads.track req, {
    type: "click"
    asset_url: url
    publisher: req.publisher
  }
