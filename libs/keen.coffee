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
    
  
  keen.errors = {
    DATA: {
      success: false
      error: "No Data Available"
    }
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

  
  keen.createDataset = (name, data)->  
    name = "#{CONFIG.keen.prefix}-#{name}"        
    console.log "KEEN Dataset Created: #{name}"
    keen.request("put", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}", data).catch (error)->
      console.log error
  
    
  keen.fetchDataset = (name, data, interval="none")->
    interval_list = {
      "yearly": "getFullYear"
      "monthly": "getMonth"
      "daily": "getDate"
      "hourly": "getHours"
      "none": "none"
    }
    interval = interval_list[interval]
    name = "#{CONFIG.keen.prefix}-#{name}"    

    keen.request("get", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{name}/results", data).then (response)->       
      results = []
      index = -1
      subframe = null
      group_by = response.metadata.dataset.query.group_by[0]
      
      for result, i in response.result
        temp_index = null
        
        if interval != "none"
          temp_date = new Date(result.timeframe.start)
          temp_index = temp_date[interval]()
        
        if not subframe
          subframe = {
            timeframe: {
              start: result.timeframe.start
            }
            value: result.value
          }
          index = temp_index
          continue
          
        if typeof subframe.value == "number"
          subframe.value += result.value
        
        else
          for temp_value in result.value
            to_add = true
            
            for value in subframe.value
              if temp_value[group_by] == value[group_by]
                value.result += temp_value.result
                to_add = false
                
            if to_add
              subframe.value.push temp_value
          
          
        if index != temp_index or i == response.result.length - 1
          subframe.timeframe.end = result.timeframe.end
          results.push(subframe)
          subframe = null
            
      if group_by?
        results = results[0].value
      
      response.result = results
      return response
  
  
  keen.fetchDefinitions = (url=null, array=[])->
    keen.request("get", url or "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets").then (response)->
      array = array.concat response.datasets
      
      if response.next_page_url
        return keen.fetchDefinitions response.next_page_url, array 
        
      return array
      
  
  keen.deleteOldDatasets = ->
    keen.fetchDefinitions().each (dataset)->
      name = dataset.dataset_name
      
      if name.indexOf(CONFIG.keen.prefix) == -1
        return LIBS.keen.deleteDataset(name)    
  
  
  keen.deleteDataset = (dataset)->
    console.log "KEEN Dataset Deleted: #{dataset}"
    keen.request("delete", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/#{dataset}")
  
  
  keen.deleteDatasets = (url=null)->
    keen.fetchDefinitions().each (dataset)->
      keen.deleteDataset dataset.dataset_name


  return keen
