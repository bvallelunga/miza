module.exports.get = (req, res, next)->
  res.render "publisher/migrate", {
    js: "publisher"
    css: "publisher", "fa"
    title: "Migration Dashboard"
  }