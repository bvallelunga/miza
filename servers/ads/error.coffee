module.exports = (err, req, res, next)->
  if CONFIG.is_prod
    LIBS.bugsnag.notify err
  
  else
    console.error err.stack or err
  
  res.send CONFIG.ads_server.denied.message