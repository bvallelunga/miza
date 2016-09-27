module.exports.get = (req, res, next)->
  LIBS.emails.render(req.params.template, [{
    data: {
      user: {
        email: "jim@bob.com"
        name: "Jim Bob"
      }
      publisher: {
        name: "Test Publisher"
      }
    }
    to: "jim@bob.com"
    host: req.get("host")
  }]).then (emails)->
    res.send emails[0].html
    
  .catch next