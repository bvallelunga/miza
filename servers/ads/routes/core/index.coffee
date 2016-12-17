utils = require "./utils"
protect = require "../protect"

module.exports.check = (req, res, next)->
  res.end req.publisher.key


module.exports.ping = (req, res, next)->
  res.end utils.pixel_tracker
  
  LIBS.models.Event.queue req, {
    type: "ping"
    publisher: req.publisher
  }

  
module.exports.impression = (req, res, next)->
  res.end utils.pixel_tracker
  
  LIBS.models.Event.queue req, {
    type: "impression"
    publisher: req.publisher
    network: req.network
  }
  
  
module.exports.router = (req, res, next)->
  encoded = utils.url_safe_decoder req.path.slice(1)
  decoded = new Buffer(encoded, 'base64').toString("ascii").split(":")
  key = decoded[0]
  url = decoded.slice(1).join(":")
  
  # Url Builder
  if url.slice(0, 2) == "//"
    url = "http:" + url
  
  else if url.indexOf("://") == -1
    url = "http://" + url
  
  req.path = encoded
  req.decoded_path = url
  
  # Ads Proxy Router
  if key == "protect"
    protect.proxy req, res, next
  
  
  
  
