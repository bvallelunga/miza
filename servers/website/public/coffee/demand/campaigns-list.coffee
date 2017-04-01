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
      
    @date_range = new DatePicker ".campaigns-listing-dashboard", @update.bind @
    
    $(".actions .action").click (e)=>
      action = $(e.currentTarget).data("action")
      campaigns = $.makeArray @data_table.column(0).checkboxes.selected()
      
      if campaigns.length == 0 or action == "delete" and not confirm("Please confirm you want to delete!")
        return
      
      $spinner = $(e.currentTarget).find(".fa-spin").show()
      $original = $(e.currentTarget).find(":not(.fa-spin)").hide()
      
      $.post("/demand/#{config.advertiser}/campaigns/update", {
        _csrf: config.csrf
        action: action
        campaigns: campaigns
      }).done =>
        $spinner.hide()
        $original.show()
        @update(@dates)
      
      .fail (error)->
        $spinner.hide()
        $original.show()
        message = error.responseJSON.message
        
        $(".container").prepend(
          "<div class='warning orange'>#{message}</div>"
        )
  
    
  build_table: ->
    @data_table = @$table.DataTable({
      "paging":   false
      "ordering": false
      "bsort":    false
      "info":     false
      "search":   false
      'columnDefs': [{
        'targets': 0,
        'checkboxes': {
          'selectRow': true
        }
      }, {
        'targets': 1,
        'render': ( data, type, row, meta )->
          return "<a href='/demand/#{config.advertiser}/campaign/#{row.id}'>#{data}</a>"
      }, {
        'targets': 2,
        'render': ( data, type, row, meta )->
          return data.toUpperCase()
      }]
      "columns": [
        { "data": "id" },
        { "data": "name" },
        { "data": "type" },
        { "data": "status" },
        { "data": "metrics.progress" },
        { "data": "metrics.impressions" },
        { "data": "metrics.clicks" }
        { "data": "metrics.ctr" }
        { "data": "metrics.spend" }
      ]
    })
  
  
  update: (dates, finished=(-> 1))->
    @dates = dates
    
    $.post("/demand/#{config.advertiser}/campaigns/list", {
      _csrf: config.csrf
      dates: dates
    }).done (response)=>
      if not response.success
        return
      
      @data_table.clear()
      @data_table.rows.add(response.results)
      @data_table.draw()
      finished()
      
    .fail finished
  

$ ->
  if $(".container").hasClass "campaigns-listing-dashboard"
    dashboard = new Dashboard()
