numeral = require "numeral"
moment = require "moment"

module.exports = (req, res, next)->

  # Header Config
  res.header 'Server', CONFIG.general.company
  res.header 'Access-Control-Allow-Credentials', true
  res.header 'Access-Control-Allow-Origin', req.get "host"
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept'
  
  #Locals
  res.locals.csrf = req.csrfToken()
  res.locals.host = "#{req.protocol}://#{req.get("host")}"
  res.locals.hostname = req.get("host")
  res.locals.url = res.locals.host + req.originalUrl
  res.locals.title = ""
  res.locals.css = ""
  res.locals.js = ""
  res.locals.site_title = CONFIG.general.company
  res.locals.site_delimeter = CONFIG.general.delimeter
  res.locals.description = CONFIG.general.description
  res.locals.company = CONFIG.general.company
  res.locals.logo = CONFIG.general.logo
  res.locals.config = {}
  res.locals.user = req.user
  res.locals.title_first = true
  res.locals.is_prod = CONFIG.isProd
  res.locals.random = if CONFIG.isProd then "" else "?r=#{Math.random()}"
  res.locals.intercom = {}
  res.locals.intercom_base = CONFIG.intercom
  res.locals.support_email = CONFIG.general.support.email
  res.locals.support_phone = CONFIG.general.support.phone
  res.locals.support_phone_clean = CONFIG.general.support.phone.replace(/\D+/g, '')
  res.locals.numeral = numeral
  res.locals.moment = moment
  res.locals.media = {
    "logo" : "/imgs/logo.png#{res.locals.random}"
    "graph": "/imgs/graph.png#{res.locals.random}"
  }
  
  if req.user?
    res.locals.intercom_base.email = req.user.email
    res.locals.intercom_base.name = req.user.name
  
  # Next
  next()
  
  