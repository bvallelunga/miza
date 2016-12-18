module.exports = (data, publisher, query)->  
  Promise.resolve().then ->    
    if not CONFIG.disable.ads_server.modifier
      replacers = require("./carbon")(publisher)
    
      for replacer in replacers
        data.content = data.content.replace replacer[0], replacer[1]
  
    return data
