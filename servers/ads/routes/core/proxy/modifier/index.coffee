obfuscator = require 'javascript-obfuscator'
modifiers = {
  dfp: require "./dfp"
  adsense: require "./adsense"
  carbon: require "./carbon"
}

module.exports = (data, publisher, network, query)->  
  Promise.resolve().then ->    
    if not CONFIG.disable.ads_server.modifier
      replacers = []
    
      if modifiers[network.slug]?
        replacers = modifiers[network.slug](publisher, network)
    
      for replacer in replacers
        data.content = data.content.replace replacer[0], replacer[1]
        
      if query.script?
        data.content = obfuscator.obfuscate(data.content).getObfuscatedCode()
        return data
    
    if query.frame?
      data.content += """
        <script type='text/javascript'>           	
          window["#{publisher.key}"] = { network: #{network.id} };   
          (function(window, base) {
            var script = document.createElement("script");
            script.src = "//" + base + "?r=" + Math.random();
            script.async = true;
            document.getElementsByTagName('head')[0].appendChild(script);
          })(window, "#{query.frame}");
        </script>
      """
  
    return data
