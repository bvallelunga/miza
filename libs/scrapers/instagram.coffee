scraper = require 'insta-scraper'
request = require "request-promise"
URL = require "url"

module.exports.profile = (username)->
  username = username.replace("http://", "").replace("@", "")

  new Promise (res, rej)->  
    scraper.getAccountMedia username, (error, response)->          
      if error? or response.length == 0
        return rej "Please make sure your profile is public and has images."
      
      user = {
        username: response[0].user.username
        profile_image: response[0].user.profile_picture
      }
      
      return res {
        image_selection: true
        link: "https://instagram.com/#{username}"
        format: "social"
        config: {
          user: user
          images: []
          action: "Follow"
        }
        images: response.slice(0, 16).map (media)->
          return media.images.standard_resolution.url
      }
      

module.exports.post = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "instagram.com"
    return Promise.reject "Please provide an instagram post url."
  
  code = url_parsed.pathname.slice(1).split("/")[1]
  request('https://www.instagram.com/p/' + code + '/?__a=1').then (response)->
    response = JSON.parse(response).graphql.shortcode_media  
    user = {
      username: response.owner.username
      profile_image: response.owner.profile_pic_url
    }
    
    images = [ response.display_url ]
    
    if response.edge_sidecar_to_children?
      images = response.edge_sidecar_to_children.edges.map (edge)->
        return edge.node.display_url
    
    return {
      image_selection: false
      link: url
      format: "social"
      config: {
        user: user
        images: images
        action: "View"
      }
      images: []
    }
    
  .catch ->
    Promise.reject "Please make sure your profile is public and has images."
