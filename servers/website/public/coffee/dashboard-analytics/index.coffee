$ ->
  downloadMetrics()
  downloadLogs()
  
  setInterval ->
    downloadMetrics()
    downloadLogs()
  
  , 30000


downloadMetrics = ->
  $.get("#{location.pathname}/metrics").done (metrics)->
    $(".ctr-metric").text metrics.ctr
    $(".impressions-metric").text metrics.impressions
    $(".clicks-metric").text metrics.clicks
    $(".assets-metric").text metrics.assets
    $(".blocked-metric").text metrics.blocked
  

downloadLogs = ->
  $.get("#{location.pathname}/logs").done (logs)->
    now = new Date()
    
    if logs.length == 0
      return $(".logs-table-message").text "We don't have any logs yet for your account."
  
    $(".logs-table-message").hide()
    $(".logs-table tbody").html("").append logs.map (log)->
      created = new Date log.created_at
          
      return $("""
        <tr class="#{ if log.protected then "protected" else "normal" }">
          <td>#{log.type}</td>
          <td>#{log.ad_network or ""}</td>
          <td>#{log.protected}</td>
          <td>#{log.ip_address}</td>
          <td>#{moment.duration(created - now).humanize(true)}</td>
        </tr>
      """)