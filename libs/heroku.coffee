Heroku = require('heroku-client')

# Exports
module.exports = ->
  if CONFIG.disable.heroku
    return {
      heroku: {}
      add_domain: Promise.resolve
      add_domain: Promise.resolve
    }


  heroku = new Heroku { 
    token: CONFIG.heroku_token 
  }
  
  add_domain = (domain)->
    LIBS.heroku.post "/apps/#{CONFIG.app_name}/domains", {
      body: { hostname: domain }
    } 
   
   
  remove_domain = (domain)->
    LIBS.heroku.delete "/apps/#{CONFIG.app_name}/domains/#{domain}"
  
  
  return {
    heroku: heroku
    add_domain: add_domain
    remove_domain: remove_domain
  }