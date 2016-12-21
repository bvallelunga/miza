module.exports = require("../template")  {
  disabled: true
  intervals: [
    ["marketing.github_cleanup"]
  ]
  config: {
    priority: "low" 
  }
}, (job)-> 
  LIBS.models.PublisherInvite.findAll({
    include: [{
      model: LIBS.models.Publisher
      as: "publisher"
    }]
  }).each (invite)->  
    Promise.all([
      invite.publisher.cloudflare_remove(invite.publisher.key)
      invite.publisher.heroku_remove(invite.publisher.endpoint)
    ]).catch(console.error).then ->
      invite.publisher.destroy()
    
    .then ->
      invite.destroy()
    
    .then ->
      console.log "Cleaned up #{invite.publisher.name}"
    