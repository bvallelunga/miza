module.exports = ->
  LIBS.models.Publisher.findAll().then (publishers)->
    domains = CONFIG.ssl_server.domains
    
    for publisher in publishers
      domains.push publisher.endpoint
  
    require('letsencrypt-express').create({
      server: CONFIG.ssl_server.server
      email: 'support@miza.io'
      agreeTos: true
      approveDomains: ["dev.miza.io"] #domains
    })