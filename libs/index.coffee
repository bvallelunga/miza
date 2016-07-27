module.exports = ->
  return {
    parse: require("./parse")
    redis: require("./redis")()
  }