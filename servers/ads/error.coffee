module.exports = (err, req, res, next)->
  if typeof err == "string" and err.indexOf("MIZA") == -1
    if CONFIG.is_prod
      LIBS.bugsnag.notify err
    
    else
      console.error err or err
  
  res.send CONFIG.ads_server.denied.message