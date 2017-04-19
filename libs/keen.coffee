Keen         = require 'keen-js'
KeenTracking = require 'keen-tracking'
KeenAnalysis = require 'keen-analysis'
request = require 'superagent'

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
      params = if method == "get" then "query" else "send"
      
      request[method](url)[params](data)
        .set('Authorization', CONFIG.keen.masterKey)
        .set('Content-Type', 'application/json')
        .end (error, result)->
          if error? then return rej error.response.error
          return res result.body
  
  
  keen.deleteDatasets = ->
    keen.request("get", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets").then (response)->
      Promise.each response.datasets, (dataset)->
        console.log "KEEN Dataset Deleted: #{dataset.dataset_name}"
        keen.request("delete", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{dataset.dataset_name}")
  
  
  keen.createDataset = (name, data)->  
    name = "#{CONFIG.keen.prefix}-#{name}"        
    console.log "KEEN Dataset Created: #{name}"
    keen.request("put", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}", data).catch (error)->
      console.log error
  
    
  keen.fetchDataset = (name, data)->
    name = "#{CONFIG.keen.prefix}-#{name}"      
    keen.request "get", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}/results", data      
    
  return keen
