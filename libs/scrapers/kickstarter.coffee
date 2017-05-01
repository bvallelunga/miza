URL = require "url"

module.exports = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "kickstarter.com" or url_parsed.pathname.indexOf("projects") == -1
    return Promise.reject "Please provide an Kickstarter project url."
  
  return Promise.resolve {
    image_selection: false
    link: url
    format: "crowdsource"
    config: {
      site: "kickstarter"
      url: url
      embed: "//#{hostname}/#{url_parsed.pathname}/widget/card.html?v=2"
      images: [""]
    }
  }
