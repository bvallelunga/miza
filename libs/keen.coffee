Keen         = require 'keen-js'
KeenTracking = require 'keen-tracking'
KeenAnalysis = require 'keen-analysis'

module.exports = ->
  return {  
    Keen: Keen
    Analysis: KeenAnalysis
    Tracking: KeenTracking
    tracking: new KeenTracking CONFIG.keen
    analysis: new KeenTracking CONFIG.keen
    scopeKey: (data)->
      Keen.utils.encryptScopedKey CONFIG.keen.masterKey, data
    
    scopedAnalysis: (key)->
      new KeenAnalysis {
        projectId: CONFIG.keen.projectId
        readKey: key
      }
  }