module.exports = (req, res, next)->

  # Header Config
  res.header 'Server', CONFIG.general.company
  res.header 'Access-Control-Allow-Credentials', true
  res.header 'Access-Control-Allow-Origin', req.get "host"
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept'
  
  # Redirect
  if "www" in req.subdomains
    return res.redirect "//#{req.hostname.split(".").slice(1).join(".")}#{req.path}"
  
  #Locals
  res.locals.csrf = if req.csrfToken then req.csrfToken() else ""
  res.locals.host = req.get "host"
  res.locals.title = ""
  res.locals.site_title = CONFIG.general.company
  res.locals.site_delimeter = CONFIG.general.delimeter
  res.locals.description = CONFIG.general.description
  res.locals.company = CONFIG.general.company
  res.locals.logo = CONFIG.general.logo
  res.locals.config = {}
  res.locals.user = req.session.user
  res.locals.title_first = true
  res.locals.random = if CONFIG.isProd then "" else "?r=#{Math.random()}"
  res.locals.search = ""
  res.locals.media = {
    "logo" : "#{res.locals.host}/imgs/logo.png#{res.locals.random}"
    "graph": "#{res.locals.host}/imgs/graph.png#{res.locals.random}"
  }
  
  # Next
  next()
  
  