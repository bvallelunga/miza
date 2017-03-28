Keen         = require 'keen-js'
KeenTracking = require 'keen-tracking'
KeenAnalysis = require 'keen-analysis'
request = require('superagent')

module.exports = ->
  keen = new Keen CONFIG.keen
  keen.Keen = Keen
  keen.Analysis = KeenAnalysis
  keen.Tracking = KeenTracking
  keen.tracking = new KeenTracking CONFIG.keen
  keen.analysis = new KeenTracking CONFIG.keen
  
  keen.scopeKey = (data)->
    Keen.utils.encryptScopedKey CONFIG.keen.masterKey, data

  keen.scopedAnalysis = (key)->
    new KeenAnalysis {
      projectId: CONFIG.keen.projectId
      readKey: key
    }
    
  keen.createCachedDataset = (name, data)->
    new Promise (res, rej)->
      request
        .put("https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}")
        .send(data)
        .set('Authorization', CONFIG.keen.masterKey)
        .set('Content-Type', 'application/json')
        .end (error, result)->
          if error? then return rej error.response.error
          return res result
  
  return keen