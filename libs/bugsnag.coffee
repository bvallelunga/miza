bugsnag = require "bugsnag"

module.exports = ->
  bugsnag.register CONFIG.bugsnag
  notify = bugsnag.notify
  
  bugsnag.notify = (data)->
    if CONFIG.disable.bugsnag
      Promise.resolve()
      
    notify(data)
  
  return bugsnag