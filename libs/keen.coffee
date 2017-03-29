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
    
  keen.request = (method, url, data)->
    new Promise (res, rej)->
      request[method](url)
        .send(data)
        .set('Authorization', CONFIG.keen.masterKey)
        .set('Content-Type', 'application/json')
        .end (error, result)->
          if error? 
            return rej error.response.error
          
          return res result.body
  
  keen.createCachedDataset = (name, data, force=false)->
    Promise.resolve().then ->
      return keen.request "get", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}"
    
    .then (definition)->
      if force
        return keen.request "delete", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}"
        
      return false   
    
    
    .catch ->
      return Promise.resolve(true) 
         
    .then (create)->
      if create != false
        keen.request "put", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}", data
    
  
  return keen