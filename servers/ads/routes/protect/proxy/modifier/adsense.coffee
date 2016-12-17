module.exports = (publisher, network)->
  return [
    [/adsbygoogle/gi, "#{publisher.key}_#{network.id}"]
    #[/adsbygoogle\-content-/gi, "#{publisher.key}_#{network.id}-content"]
    #[/google\_ad\_/gi, "#{publisher.key}_#{network.id}_"]
  ]