Analytics = require 'analytics-node'

module.exports = ->
  sources = {}
  
  for name, secret of CONFIG.segment
    sources[name] = new Analytics secret

  return sources