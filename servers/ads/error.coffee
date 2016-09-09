module.exports = (err, req, res, next)->
  console.error err   
  res.send CONFIG.ads_server.denied.message