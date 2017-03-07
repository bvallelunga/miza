class Dashboard

  charts: {}
  $table: null
  data_table: null
  $search: null
  
  
  constructor: ->
    @$search = $(".display .search-box input")
    @$table = $(".display .table-body table").show()
  
    @bindings()
    @build_table()
    @build_charts()
    @update()
    
  
  bindings: ->
    @$search.keyup =>
      @data_table.column(1).search(@$search.val()).draw()
      
    $(".actions:not(.disabled) .action").click (e)=>
      industries = $.makeArray @data_table.column(0).checkboxes.selected()
      
      if industries.length == 0
        return
      
      $.post("/demand/#{config.advertiser}/campaign/#{config.campaign}/industries", {
        _csrf: config.csrf
        action: $(e.currentTarget).data("action")
        industries: industries
      }).done(=> @update()).fail (error)->
        message = error.responseJSON.message
        
        $(".container").prepend(
          "<div class='warning orange'>#{message}</div>"
        )
        
        window.scrollTo(0,0);
    
    
  build_table: ->
    @data_table = @$table.DataTable({
      "paging":   false
      "ordering": false
      "info":     false
      "search":   false
      'columnDefs': [{
        'targets': 0,
        'checkboxes': {
          'selectRow': true
        }
      }]
      "columns": [
        { "data": "id" },
        { "data": "name" },
        { "data": "status" },
        { "data": "metrics.impressions" },
        { "data": "metrics.clicks" }
        { "data": "metrics.cpm" },
        { "data": "metrics.budget" },
        { "data": "metrics.spend" }
      ]
      'order': [[1, 'asc']]
    })
    
  
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
        tooltip: {
          format: {
            name: (name, ratio, id, index)-> "Impressions"
          }
        }
      })
      .prepare()
        
  
  update: ->
    @data_table.clear() 
  
    $.get("/demand/#{config.advertiser}/campaign/#{config.campaign}/industries").done (response)=>
      if not response.success
        return
        
      @data_table.rows.add(response.results)
      @data_table.draw()    
  
    $.get("/demand/#{config.advertiser}/campaign/#{config.campaign}/charts").done (response)=>
      for name, data of response
        chart = @charts[name]
                
        if data.success
          chart.data(data.result).render()
        
        else 
          chart.message(data.error)
    
      finished()



$ ->
  if not $(".container").hasClass "campaign-dashboard"
    return

  dashboard = new Dashboard()