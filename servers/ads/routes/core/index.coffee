module.exports.utils = utils = require "./utils"
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
