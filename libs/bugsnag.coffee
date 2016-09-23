bugsnag = require "bugsnag"

module.exports = ->
  bugsnag.register CONFIG.bugsnag
  return bugsnag