$ ->
  billingMetrics()
  billingLogs()


billingMetrics = ->
  $.get("#{location.pathname}/metrics", {
    date: new Date()
  }).done (reports)->       
    $(".billing-table .loading").remove() 
    $(".owed-metric").text reports.totals.owed   
    $(".billing-table tbody").prepend reports.all.map (report)->
      return $("""
        <tr>
          <td>#{moment(report.created_at).format("MMM Do, YYYY")}</td>
          <td>#{report.impressions}</td>
          <td>#{report.cpm}</td>
          <td>#{report.impressions_owed}</td>
        </tr>
      """)
  

billingLogs = ->
  $.get("#{location.pathname}/logs", {
    date: new Date()
  }).done (logs)->
    now = new Date()
    
    $(".logs-table-message")
      .toggle(logs.length == 0)
      .text "We don't have any logs yet for your account."
    
    $(".logs-table tbody").html logs.map (log)->          
      return $("""
        <tr class="#{ log.status }">
          <td>#{log.id}</td>
          <td>#{log.amount}</td>
          <td>#{log.status}</td>
          <td>#{log.card.brand} #{log.card.last4}</td>
          <td>#{moment(log.created).format("MMM Do, YYYY")}</td>
        </tr>
      """)
