module.exports = {
  
  pixel_tracker: new Buffer("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7", "base64")
  
  decoder: (str)->
    str = (str + '===').slice(0, str.length + (str.length % 4))
    return str.replace(/-/g, '+').replace(/_/g, '/')

}