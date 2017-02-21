Keen         = require 'keen-js'
KeenTracking = require 'keen-tracking'
KeenAnalysis = require 'keen-analysis'

module.exports = ->
  return {  
    tracking: new KeenTracking CONFIG.keen
    analysis: new KeenTracking CONFIG.keen
    scopeKey: (data)->
      Keen.utils.encryptScopedKey CONFIG.keen.masterKey, data
      
    KeenAnalysis: (key)->
      new KeenAnalysis {
        projectId: CONFIG.keen.projectId
        readKey: key
      }
  }