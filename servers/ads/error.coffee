module.exports = (err, req, res, next)->
  if err != "MIZA DOWNLOADER"
    if CONFIG.is_prod
      LIBS.bugsnag.notify err
    
    else
      console.error err or err
  
  res.send CONFIG.ads_server.denied.message