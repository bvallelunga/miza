module.exports.past_date = (range, date)->
  range_at = if date? then new Date(date) else new Date()
  
  if range == "month"
    range_at.setMonth range_at.getMonth() - 1
    range_at.setDate 1
    
  if range == "month+1"
    range_at.setMonth range_at.getMonth() + 1
    range_at.setDate 1
    
  else if range == "week"
    range_at = new Date(range_at.getFullYear(), range_at.getMonth(), range_at.getDate() - range_at.getDay()+1)
  
  range_at.setHours 0, 0, 0, 0
  return range_at