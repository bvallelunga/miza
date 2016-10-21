numeral = require "numeral"
moment = require "moment"
random_slug = Math.random().toString(36).substr(2, 20)

module.exports = (req, res, next)->

  # Header Config
  res.header 'Server', CONFIG.general.company
  res.header 'Access-Control-Allow-Credentials', true
  res.header 'Access-Control-Allow-Origin', req.get "host"
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept'
  
  #Locals  
  if req.csrfToken?
    res.locals.csrf = req.csrfToken() 
  
  res.locals.host = "https://#{req.get("host")}"
  res.locals.hostname = req.get("host")
  res.locals.url = res.locals.host + req.originalUrl
  res.locals.path = req.originalUrl
  res.locals.title = ""
  res.locals.css = ""
  res.locals.js = ""
  res.locals.site_title = CONFIG.general.company
  res.locals.site_delimeter = CONFIG.general.delimeter
  res.locals.description = CONFIG.general.description
  res.locals.company = CONFIG.general.company
  res.locals.logo = CONFIG.general.logo
  res.locals.config = {}
  res.locals.user = req.user or null
  res.locals.title_first = true
  res.locals.is_prod = CONFIG.is_prod
  res.locals.changelog = false
  res.locals.changelog_key = CONFIG.changelog
  res.locals.random = "r=#{random_slug}"
  res.locals.mixpanel = CONFIG.mixpanel.key
  res.locals.intercom = ((user)->      
    if not user? or user.is_demo
      return {}
            
    return { 
      user_id: user.id
      name: user.name
      email: user.email
      stripe: user.stripe_id
      card: user.stripe_card
      admin: user.is_admin
    }
  )(req.user)
  res.locals.intercom_base = {
    app_id: CONFIG.intercom.app_id
  }
  res.locals.support_email = CONFIG.general.support.email
  res.locals.support_phone = CONFIG.general.support.phone
  res.locals.support_phone_clean = CONFIG.general.support.phone.replace(/\D+/g, '')
  res.locals.numeral = numeral
  res.locals.moment = moment
  res.locals.media = {
    "logo" : "#{res.locals.host}/imgs/logo.png?#{res.locals.random}"
    "graph": "#{res.locals.host}/imgs/graph.png?#{res.locals.random}"
  }
    
  # Next
  next()
  
  