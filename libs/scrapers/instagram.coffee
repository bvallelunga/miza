scraper = require 'insta-scraper'
numeral = require "numeral"
URL = require "url"

module.exports.profile = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "instagram.com"
    return Promise.reject "Please provide an instagram profile url."
    
  username = url_parsed.pathname.slice(1).split("/")[0]

  new Promise (res, rej)->
    scraper.getAccountInfo username, (error, accountInfo)->  
      if error? or not accountInfo?
          return rej "This user does not have a public account with images."
  
      scraper.getAccountMedia username, (error, response)->      
        if error? or response.length == 0
          return rej "This user does not have a public account with images."
        
        user = {
          username: response[0].user.username
          followers: numeral(accountInfo.followed_by.count).format "1a"
          profile_image: response[0].user.profile_picture
        }
        
        return res {
          image_selection: true
          link: url
          format: "social"
          config: {
            user: user
            images: []
          }
          images: response.slice(0, 16).map (media)->
            return media.images.standard_resolution.url
        }