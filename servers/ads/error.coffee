module.exports = (err, req, res, next)->
  message = err.message or err
    
  if err.errors?
    message = err.errors.map (error)->
      if error.type == "unique violation"
        return "#{error.path} is already in use"
      
      return error.message
    
    .join "\n"
    
  res.status(403).json {
    success: false
    message: message
  }