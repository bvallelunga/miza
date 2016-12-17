module.exports = (err, req, res, next)->
  console.error err.stack   
  res.send CONFIG.ads_server.denied.message