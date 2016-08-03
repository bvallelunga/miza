module.exports = (data, publisher)->  
  Promise.resolve().then ->  
    replacers = [
      [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1#{publisher.key}$2"]
      [/div\-gpt\-ad/gi, publisher.key]
      [/google\_ads\_iframe/gi, "#{publisher.key}_iframe"]
      [/google\_/gi, "#{publisher.key}_"]
      [/img\_ad/gi, "#{publisher.key}_img"]
      [/google\-ad\-content-/gi, "#{publisher.key}-content"]
    ]
    
    for replacer in replacers
      data.content = data.content.replace replacer[0], replacer[1]
  
    return data
