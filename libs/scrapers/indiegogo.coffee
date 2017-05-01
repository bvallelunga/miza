URL = require "url"

module.exports = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "indiegogo.com" or url_parsed.pathname.indexOf("projects") == -1
    return Promise.reject "Please provide an Indiegogo project url."
    
  url = "//#{hostname}/#{url_parsed.pathname}"
  
  return Promise.resolve {
    image_selection: false
    link: url
    format: "crowdsource"
    config: {
      site: "indiegogo"
      url: url
      embed: url.replace("/projects/", "/project/") + "/embedded"
      images: [""]
    }
  }
