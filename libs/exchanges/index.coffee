module.exports = {
  
  smaato: require "./smaato"
  carbon: require "./carbon"
  fetch: (req)->        
    LIBS.exchanges.smaato({
      referer: req.get('referrer')
      "user-agent": req.get("user-agent")
    }, {
      ref: req.get('referrer')
      width: req.query.width
      height: req.query.height
      devip: req.ip or req.ips
      session: req.cookies.session
    }).catch (error)->
      if error != "Miza: Could not parse ad"
        return Promise.reject error
        
      LIBS.exchanges.carbon()

}