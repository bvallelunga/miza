class ReportsDashboard

  metrics: (range)->
    $(".impressions-metric").html "&nbsp;"
    $(".clicks-metric").html "&nbsp;"
    $(".owed-metric").html "&nbsp;"
    $(".revenue-metric").html "&nbsp;"
    $(".protected-metric").html "&nbsp;"
    $("tr.publisher .data").text ""
    
    to_date = @date_to_string new Date()
    from_date = @date_from_range range
    
    Promise.map config.publishers, (publisher)=>
      $publisher = $("tr.#{publisher.key}")
      publisher_query = """
        event.properties["Publisher ID"] == #{publisher.id}
      """
  
      Promise.props({
        impressions: @events from_date, to_date, {
          event: "ADS.EVENT.Impression" 
          filter: """
            event.properties.Protected == true && #{publisher_query}
          """
        }
        clicks: @events from_date, to_date, {
          event: "ADS.EVENT.Click" 
          filter: """
            event.properties.Protected == true && #{publisher_query}
          """
        }
        all_pings: @events from_date, to_date, {
          event: "ADS.EVENT.Ping" 
          filter: publisher_query
        }
        protected_pings: @events from_date, to_date, {
          event: "ADS.EVENT.Ping" 
          filter: """
            event.properties.Protected == true && #{publisher_query}
          """
        }
      }).then (props)->
        props.revenue = props.impressions/1000 * publisher.industry.cpm
        props.owe = props.revenue * publisher.industry.fee
        $publisher.find(".protected").text numeral(props.protected_pings/(props.all_pings or 1)).format("0%")
        $publisher.find(".revenue").text numeral(props.revenue).format("$0[,]000a")
        $publisher.find(".owed").text numeral(props.owe).format("$0[,]000a")
        return props
        
    .then (publishers)->
      totals = {
        clicks: 0
        impressions: 0
        owe: 0
        revenue: 0
        protected_pings: 0
        all_pings: 0
      }
    
      for publisher in publishers    
        totals.clicks += publisher.clicks
        totals.impressions += publisher.impressions
        totals.owe += publisher.owe
        totals.revenue += publisher.revenue
        totals.all_pings += publisher.all_pings
        totals.protected_pings += publisher.protected_pings
        
      $(".impressions-metric").html numeral(totals.impressions).format("0[.]0a")
      $(".clicks-metric").html numeral(totals.clicks).format("0[.]0a")
      $(".owed-metric").html numeral(totals.owe).format("$0[,]000[.]00a")
      $(".revenue-metric").html numeral(totals.revenue).format("$0[,]000.00a")
      $(".protected-metric").html numeral(totals.protected_pings/(totals.all_pings or 1)).format("0%")



  events: (from_date, to_date, query)->
    MP.api.jql("""
      function main() {
        return Events({
          from_date: "#{from_date}",
          to_date: "#{to_date}",
          event_selectors: [{event: "#{query.event}"}]
        }).filter(function(event) {
          return #{query.filter}
        }).reduce(mixpanel.reducer.count())
      }
    """).then (results)->
      return results[0] || 0
          
  
  date_to_string: (date)->
    return [
      date.getFullYear()
      date.getMonth() + 1
      date.getDate()
    ].join("-")
  
  
  date_from_range: (range)->
    range_at = new Date()
    
    if range == "month"
      range_at.setMonth range_at.getMonth() - 1
      range_at.setDate 1
      
    else if range == "week"
      range_at = new Date(range_at.getFullYear(), range_at.getMonth(), range_at.getDate() - range_at.getDay()+1)
    
    range_at.setHours 0, 0, 0, 0
    
    return @date_to_string range_at
  
  
  
$ ->
  MP.api.setCredentials config.mixpanel_secret
  dashboard = new ReportsDashboard()
  dashboard.metrics $(".range-toggle .active").data("range")
  
  $(".range-toggle div").click ->
    $(".range-toggle div").removeClass "active"
    $(this).addClass "active"
    dashboard.metrics $(".range-toggle .active").data("range")

