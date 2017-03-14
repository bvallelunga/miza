app = require('express')()

module.exports = (srv)->
  
  # Routes  
  app.get "/*", (req, res, next)->
    res.send "Please migrate your account to Miza Network"
  
  
  # Export
  return app
