module.exports.past_date = (range)->
  range_at = new Date()
  
  if range == "month"
    range_at.setUTCMonth range_at.getUTCMonth() - 1
    range_at.setUTCDate 1
    
  if range == "month+1"
    range_at.setUTCMonth range_at.getUTCMonth() + 1
    range_at.setUTCDate 1
    
  else if range == "week"
    range_at = new Date(range_at.getFullYear(), range_at.getMonth(), range_at.getDate() - range_at.getDay()+1)
  
  range_at.setUTCHours 0, 0, 0, 0
  return range_at