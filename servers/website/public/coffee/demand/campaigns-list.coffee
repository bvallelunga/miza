class Dashboard

  $table: null
  data_table: null
  $search: null
  date_range: null
  dates: {}
  
  
  constructor: ->
    @$search = $(".display .search-box input")
    @$table = $(".display .table-body table").show()
  
    @build_table()
    @bindings()
  
  
  bindings: ->
    @$search.keyup =>
      @data_table.column(1).search(@$search.val()).draw()
      
    @date_range = new DatePicker ".campaigns-dashboard", @update.bind @
    
    $(".actions .action").click (e)=>
      campaigns = @data_table.column(0).checkboxes.selected()
      
      $.post("#{window.location.pathname}/update", {
        _csrf: config.csrf
        action: $(e.currentTarget).data("action")
        campaigns: $.makeArray campaigns
      }).done =>
        @update(@dates)
  
    
  build_table: ->
    @data_table = @$table.DataTable({
      "paging":   false
      "ordering": false
      "info":     false
      "search": false
      'columnDefs': [{
        'targets': 0,
        'checkboxes': {
          'selectRow': true
        }
      }, {
        'targets': 1,
        'render': ( data, type, row, meta )->
          data = '<a href="' + window.location.pathname + '/' + row.id + '">' + data + '</a>'
          return data;
      }]
      "columns": [
        { "data": "id" },
        { "data": "name" },
        { "data": "status" },
        { "data": "budget" },
        { "data": "impressions" },
        { "data": "clicks" }
        { "data": "spend" }
      ]
      'order': [[1, 'asc']]
    })
  
  
  update: (dates, finished=(-> 1))->
    @dates = dates
    @data_table.clear()
  
    $.post("#{window.location.pathname}/list", {
      _csrf: config.csrf
      dates: dates
    }).done (response)=>
      if not response.success
        return
        
      @data_table.rows.add(response.results)
      @data_table.draw()
      finished()
      
    .fail finished
  

$ ->
  if $(".container").hasClass "campaigns-listing-dashboard"
    dashboard = new Dashboard()
