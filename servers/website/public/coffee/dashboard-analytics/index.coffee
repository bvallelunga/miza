$ ->
  $.get("#{location.pathname}/metrics").done (metrics)->
    $(".revenue-metric").text metrics.revenue
    $(".impressions-metric").text metrics.impressions
    $(".clicks-metric").text metrics.clicks
    $(".assets-metric").text metrics.assets
    $(".blocked-metric").text metrics.blocked
  
  
  $.get("#{location.pathname}/logs").done (logs)->
    now = new Date()
  
    $(".logs-table tbody").append logs.map (log)->
      created = new Date log.created_at
          
      return $("""
        <tr>
          <td>#{log.type}</td>
          <td>#{log.ip_address}</td>
          <td>#{log.protected}</td>
          <td>#{moment.duration(created - now).humanize(true)}</td>
        </tr>
      """)