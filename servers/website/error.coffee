module.exports = (err, req, res, next)->
  console.error err.stack or err
  message = err.message or err
  csrf_token = ""
  
  if req.csrfToken?
    csrf_token = req.csrfToken()
  
  if err.code == 'EBADCSRFTOKEN'
    message = "Invalid CSRF token!"
    
  if err.errors?
    message = err.errors.map (error)->
      if error.type == "unique violation"
        return "#{error.path} is already in use"
      
      return error.message
    
    .join "\n"
  
  if not req.xhr
    return res.redirect "/"  
  
  res.status(403).json {
    success: false
    message: message
    csrf: csrf_token
  }