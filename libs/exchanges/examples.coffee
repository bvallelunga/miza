module.exports = (req, res)->
  example = req.query.creative_override.split("_")[1]
  profile = req.query.creative_override.split("_")[2]
  
  Promise.resolve().then ->
    if example == "twitter"
      LIBS.scrapers.twitter.account("https://twitter.com/#{profile or "nike"}")
      
    
    else if example == "soundcloud"
      LIBS.scrapers.soundcloud("https://soundcloud.com/#{profile or "diplo/mo-final-song-jauz-x-diplo-remix"}")
      
    else if example == "instagram"
      return {
        format: "social"
        link: "https://www.instagram.com/katandkale"
        config: {
          user: {
            username: "katandkale"
            profile_image: "https://scontent.cdninstagram.com/t51.2885-19/1799860_445232962284905_970902659_a.jpg"
          }
          images: [
            "https://scontent.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/c0.80.1080.1080/14727408_1768447966754627_34837321551446016_n.jpg"
#             "https://scontent.cdninstagram.com/t51.2885-15/e35/11821245_1623895264533870_612768438_n.jpg"
#             "https://scontent.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/14712433_1398235010239439_8374150044865003520_n.jpg"
#             "https://scontent.cdninstagram.com/t51.2885-15/e35/11849940_896975683713417_97519862_n.jpg"
          ]
          action: "On Instagram"
        }
      }
      
  .then (data)->
    LIBS.models.Creative.build(data)