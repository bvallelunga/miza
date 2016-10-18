Cloudflare = require "cloudflare"

module.exports = ->
  cloudflare = new Cloudflare CONFIG.cloudflare
  cloudflare.Cloudflare = Cloudflare
  return cloudflare