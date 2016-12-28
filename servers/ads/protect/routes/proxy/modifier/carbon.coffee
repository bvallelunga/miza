module.exports = (publisher)->
  network = LIBS.models.defaults.carbon_network

  return [
    [/('|")_carbonads_js('|")/gi, "$1#{publisher.key}_#{network.id}_js$2"]
    [/('|")_carbonads_projs('|")/gi, "$1_#{publisher.key}_#{network.id}_projs$2"]
    [/('|")carbonads_('|")/gi, "$1#{publisher.key}_#{network.id}_$2"]
    [/('|")carbonads('|")/gi, "$1#{publisher.key}_#{network.id}$2"]
    [/('|")carbon-([A-Za-z0-9]*?)('|")/gi, "$1#{publisher.key}_#{network.id}-$2$3"]
  ]