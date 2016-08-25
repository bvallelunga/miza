module.exports = (publisher, network)->
  return [
#     [/carbon\-/gi, "#{publisher.key}_#{network.id}-"]
#     [/\_carbonads\_js/gi, "#{publisher.key}_#{network.id}_js"]
#     [/carbonads/gi, "#{publisher.key}_#{network.id}_sda"]
      [/('|")_carbonads_projs('|")/gi, "$1_#{publisher.key}_#{network.id}_projs$2"]
      [/('|")_carbonads_js('|")/gi, "$1_#{publisher.key}_#{network.id}_js$2"]
      [/('|")carbon-wrap('|")/gi, "$1_#{publisher.key}_#{network.id}-wrap$2"]
  ]