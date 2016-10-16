Github = require "github"

module.exports = ->
  github = new Github({
    Promise: Promise
  })
  
  github.authenticate({
    type: "token"
    token: CONFIG.github
  })
  
  return github