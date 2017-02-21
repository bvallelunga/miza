class Dashboard 

  client: null
  collection: "ads.event"
  timeframe: {}
  charts: {}
  
  
  constructor: ->
    @client = new Keen config.keen
    @build_charts()
    
  
  build_charts: ->
    # Impressions Chart
    @charts.impressions_chart = new Keen.Dataviz()
      .el('.chart.impressions')
      .height(250)
      .type('area-spline')
      .title("Paid Impressions")
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
            }
          }
        }
        point: {
          show: false
        }
        tooltip: {
          format: {
            name: (name, ratio, id, index)-> "Impressions"
          }
        }
      })
      .prepare()
  
    # Impression Chart
    @charts.impression_count = new Keen.Dataviz()
      .el('.chart.impression-count')
      .height(250)
      .title('Paid Impressions')
      .type('metric')
      .colors(['#FE6672'])
      .prepare()
      
    # Click Count
    @charts.click_count = new Keen.Dataviz()
      .el('.chart.click-count')
      .height(250)
      .title('Paid Clicks')
      .type('metric')
      .colors(['#8A8AD6'])
      .prepare()
      
    
    # Views Count
    @charts.view_count = new Keen.Dataviz()
      .el('.chart.visitors-count')
      .height(250)
      .title('Page Views')
      .type('metric')
      .colors(['#EEB058'])
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
    $.get("/publisher/#{config.publisher}/analytics/metrics", {
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
  dashboard = new Dashboard()
  
  Keen.ready ->
    new DatePicker ".analytics-dashboard", (start, end, finished)->
      dashboard.update {
        start: start
        end: end
      }, finished
