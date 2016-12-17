module.exports = (publisher, network)->
  return [
    [/([^a-zA-Z\d\s:])?googletag([^a-zA-Z\d\s:]|$)/gi, "$1#{publisher.key}_#{network.id}$2"]
    [/div\-gpt\-ad/gi, "#{publisher.key}_#{network.id}"]
    [/google\_ads\_iframe/gi, "#{publisher.key}_#{network.id}_iframe"]
    [/google\_/gi, "#{publisher.key}_#{network.id}_"]
    [/img\_ad/gi, "#{publisher.key}_#{network.id}_img"]
    [/google\-ad\-content-/gi, "#{publisher.key}_#{network.id}-content"]
  ]