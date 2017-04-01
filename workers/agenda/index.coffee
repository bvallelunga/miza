fs = require 'fs'

require("../../startup") true, ->
  
  # Load Workers
  for directory in fs.readdirSync __dirname
    path = "#{__dirname}/#{directory}"

    if fs.statSync(path).isDirectory()
      for file in fs.readdirSync path
        filePath = "#{path}/#{file}"
        
        if filePath.indexOf(".coffee") == -1
          continue
                
        worker = require filePath
        
        if worker.is_worker
          worker.init()

  
  # Start agenda
  LIBS.agenda.start()
  
  
  # Graceful Shutdown
  graceful = ->
    LIBS.agenda.stop ->
      process.exit 0
  
  process.on 'SIGTERM', graceful
  process.on 'SIGINT', graceful