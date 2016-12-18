module.exports = (publisher, network)->
  return [
    [/('|")_carbonads_js('|")/gi, "$1#{publisher.key}_js$2"]
    [/('|")_carbonads_projs('|")/gi, "$1_#{publisher.key}_projs$2"]
    [/('|")carbonads_('|")/gi, "$1#{publisher.key}_$2"]
    [/('|")carbonads('|")/gi, "$1#{publisher.key}$2"]
    [/('|")carbon-([A-Za-z0-9]*?)('|")/gi, "$1#{publisher.key}-$2$3"]
  ]