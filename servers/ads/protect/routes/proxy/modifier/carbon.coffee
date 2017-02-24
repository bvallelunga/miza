module.exports = (publisher)->
  return [
    [/('|")_carbonads_js('|")/gi, "$1#{publisher.key}_5_js$2"]
    [/('|")_carbonads_projs('|")/gi, "$1_#{publisher.key}_5_projs$2"]
    [/('|")carbonads_('|")/gi, "$1#{publisher.key}_5_$2"]
    [/('|")carbonads('|")/gi, "$1#{publisher.key}_5$2"]
    [/('|")carbon-([A-Za-z0-9]*?)('|")/gi, "$1#{publisher.key}_5-$2$3"]
  ]