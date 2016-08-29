module.exports = {
  
  pixel_tracker: new Buffer("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7", "base64")
  random_slug: Math.random().toString(36).substr(2, 20)
  obfuscator: {
    keepLinefeeds:      false
    keepIndentations:   false
    encodeStrings:      true
    encodeNumbers:      true
    moveStrings:        true
    replaceNames:       true
    variableExclusions: [ '^_get_', '^_set_', '^_mtd_' ]
  }
}