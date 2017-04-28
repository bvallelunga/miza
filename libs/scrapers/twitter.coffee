URL = require "url"
twitter = require "scrape-twitter"

module.exports.account = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "twitter.com"
    return Promise.reject "Please provide an twitter account url."
    
  username = url_parsed.pathname.slice(1).split("/")[0]  
  
  twitter.getUserProfile(username).then (account)->    
    return  {
      image_selection: false
      link: url
      format: "twitter"
      config: {
        user: {
          username: account.screenName
          name: account.name
          bio: account.bio
          url: account.url
          tweets: account.tweetCount
          followers: account.followerCount
          profile_image: account.profileImage
          background_image: account.backgroundImage
        }
        action: "Follow on Twitter"
        images: [
          account.profileImage,
          account.backgroundImage
        ]
      }
      images: []
    }