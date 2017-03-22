class Dashboard 

  timeframe: {}
  charts: {}
  
  
  constructor: ->
    @build_charts()
    
  
  build_charts: ->
    # Impressions Chart
    @charts.impressions_chart = new Keen.Dataviz()
      .el('.chart.impressions')
      .height(250)
      .type('area-spline')
      .title(" ")
      .chartOptions({
        axis: {
          x: {
            inner: false
            type: 'timeseries'
            tick: {
              outer: false
              format: '%m-%d'
            } 
          }
          y: {
            inner: false
            tick: {
              outer: false
              format: (x)-> 
                return if parseInt(x) == x then x else null
            }
          }
        }
        point: {
          show: true
        }
        legend: {
          show: false
        }
      })
      .prepare()
  
    # Impression Chart
    @charts.impression_count = new Keen.Dataviz()
      .el('.chart.impression-count')
      .height(180)
      .title('Impressions')
      .type('metric')
      .colors([ 'transparent' ])
      .prepare()
      
    # Click Count
    @charts.click_count = new Keen.Dataviz()
      .el('.chart.click-count')
      .height(180)
      .title('Clicks')
      .type('metric')
      .colors([ 'transparent' ])
      .prepare()
      
    
    # Views Count
    @charts.view_count = new Keen.Dataviz()
      .el('.chart.visitors-count')
      .height(180)
      .title('Page Views')
      .type('metric')
      .colors([ 'transparent' ])
      .prepare()
      
      
    # CTR Rate
    @charts.ctr_count = new Keen.Dataviz()
      .el('.chart.ctr-count')
      .height(180)
      .title('Click Rate')
      .type('metric')
      .colors([ 'transparent' ])
      .chartOptions({ 
        suffix: "%" 
      })
      .prepare()
    
    
    # Fill Rate
    @charts.fill_count = new Keen.Dataviz()
      .el('.chart.fill-count')
      .height(180)
      .title('Fill Rate')
      .type('metric')
      .colors([ 'transparent' ])
      .chartOptions({ 
        suffix: "%" 
      })
      .prepare()
    
    
    # Protection Rate
    @charts.protection_count = new Keen.Dataviz()
      .el('.chart.protection-count')
      .height(180)
      .title('Ad Block Rate')
      .type('metric')
      .colors([ 'transparent' ])
      .chartOptions({ 
        suffix: "%" 
      })
      .prepare()
      
      
    # Browsers Chart
    @charts.browsers_chart = new Keen.Dataviz()
      .el('.chart.browsers')
      .height(250)
      .type('donut')
      .title("Browsers")
      .chartOptions({
        size: {
          height: 220
        }
        legend: {
          position: "right"
        }
      })
      .prepare()
     
     
    # Devices Chart
    @charts.devices_chart = new Keen.Dataviz()
      .el('.chart.devices')
      .height(250)
      .type('donut')
      .title("Operating Systems")
      .chartOptions({
        size: {
          height: 220
        }
        legend: {
          position: "right"
        }
      })
      .prepare()
  
  
  update: (timeframe, finished)->
    $.get("/supply/#{config.publisher}/analytics/metrics", {
      timeframe: timeframe
    }).done (response)=>
      for name, data of response
        chart = @charts[name]
                
        if data.success
          chart.data(data.result).render()
        
        else 
          chart.message(data.error)
    
      finished()
  

$ ->
  if not $(".container").hasClass "analytics-dashboard"
    return
  
  dashboard = new Dashboard()
  
  Keen.ready ->
    new DatePicker ".analytics-dashboard", (dates, finished)->
      dashboard.update dates, finished
