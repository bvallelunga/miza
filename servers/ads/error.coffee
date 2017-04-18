module.exports = (err, req, res, next)->
  if typeof err == "string" and err.indexOf("MIZA") == -1 and CONFIG.is_prod
    LIBS.bugsnag.notify err
  
  console.error err
  res.send CONFIG.ads_server.denied.message