URL = require "url"

module.exports = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "soundcloud.com"
    return Promise.reject "Please provide an SoundCloud url."
  
  url = url.replace("www.", "")
  
  return Promise.resolve {
    image_selection: false
    link: url
    format: "soundcloud"
    size: "300x370"
    config: {
      url: url
      images: [""]
    }
  }
