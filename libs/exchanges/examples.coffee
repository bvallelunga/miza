module.exports = (req, res)->
  example = req.query.creative_override.split("_")[1]
  profile = req.query.creative_override.split("_")[2]
  
  Promise.resolve().then ->
    if example == "twitter"
      return LIBS.scrapers.twitter.account(profile or "nike")
      
    else if example == "indeed"
      return LIBS.exchanges.indeed(req, res).then (data)->
        return data.toJSON()
      
    else if example == "soundcloud"
      LIBS.scrapers.soundcloud("https://soundcloud.com/#{profile or "bassk-music/odeza-all-we-need-bassk-remix"}")
      
    else if example == "kickstarter"
      LIBS.scrapers.kickstarter("https://kickstarter.com/#{profile or "projects/creatiodesign/mellow"}")
      
    else if example == "etsy"
      LIBS.scrapers.etsy.product("https://www.etsy.com/#{profile or "listing/483457805/ash-wood-mousepad"}")  
      
    
    else if example == "enterprise"
      return {
        format: "social"
        link: "http://www.nike.com"
        config: {
          user: {
            username: "nike"
            profile_image: "https://instagram.fsnc1-1.fna.fbcdn.net/t51.2885-19/s320x320/17126848_1779368432381854_3589478532054515712_a.jpg"
          }
          images: [
            "https://instagram.fsnc1-1.fna.fbcdn.net/t51.2885-15/s640x640/e15/17267994_662187833965528_317544803552198656_n.jpg"
            "https://instagram.fsnc1-1.fna.fbcdn.net/t51.2885-15/e15/p640x640/17587195_754539068042759_7184793937549197312_n.jpg"
            "https://instagram.fsnc1-1.fna.fbcdn.net/t51.2885-15/e35/16123569_972384529562038_1390565919155027968_n.jpg"
          ]
          action: "Customize on Nike"
        }
      }
      
    
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
