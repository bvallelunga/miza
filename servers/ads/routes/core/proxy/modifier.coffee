module.exports = (data, publisher, network, query)->  
  Promise.resolve().then ->  
    replacers = [
      [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1#{publisher.key}_#{network.id}$2"]
      [/div\-gpt\-ad/gi, "#{publisher.key}_#{network.id}"]
      [/google\_ads\_iframe/gi, "#{publisher.key}_#{network.id}_iframe"]
      [/google\_/gi, "#{publisher.key}_#{network.id}_"]
      [/img\_ad/gi, "#{publisher.key}_#{network.id}_img"]
      [/google\-ad\-content-/gi, "#{publisher.key}_#{network.id}-content"]
      [/adsbygoogle\-content-/gi, "#{publisher.key}_#{network.id}-content"]
      [/adsbygoogle/gi, "#{publisher.key}_#{network.id}"]
      [/google\_ad\_/gi, "#{publisher.key}_#{network.id}_"]
    ]
    
    if not CONFIG.debug.ads_server.modifier
      for replacer in replacers
        data.content = data.content.replace replacer[0], replacer[1]
    
    
    if query.frame?
      data.content += """"
        <script type='text/javascript'>  
          window["#{publisher.key}"] = { network: #{network.id} };   	
          (function(window) {
            var script = document.createElement("script");
            script.src = "#{query.frame}?r=" + Math.random();
            script.async = true;
            document.getElementsByTagName('head')[0].appendChild(script);
          })(window);
        </script>
      """
  
    return data
