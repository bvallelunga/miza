module.exports = {
  AD_NOT_FOUND: "MIZA: No ads were found"
  BOT_FOUND: "MIZA: Bot was found"
  
  is_valid: (error)->
    values = Object.keys(@).map((key)=> return @[key])
    return error? and values.indexOf(error.message or error) == -1
}