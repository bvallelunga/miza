KeenTracking = require 'keen-tracking'
KeenAnalysis = require 'keen-analysis'

module.exports = ->
  return {
    tracking: new KeenTracking CONFIG.keen
    analysis: new KeenTracking CONFIG.keen
  }