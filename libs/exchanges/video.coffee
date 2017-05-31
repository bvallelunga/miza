module.exports = (req, res)->
  videos = [ "mobicast" ]
  video = req.query.video or videos[ Math.floor(Math.random() * videos.length) ]
 
  creative = LIBS.models.Creative.build({
    format: "video"
    config: {
      video: video
    }
    trackers: []
    link: ""
  })
  
  creative.id = video
  creative.campaign_id = video
  creative.advertiser_id = video
  return Promise.resolve creative