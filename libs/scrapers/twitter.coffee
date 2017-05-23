twitter = require "scrape-twitter"

module.exports.account = (username)->
  username = username.replace("http://", "").replace("@", "") 
  
  twitter.getUserProfile(username).then (account)->    
    return  {
      image_selection: false
      link: "https://twitter.com/#{username}"
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