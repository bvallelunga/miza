$ ->
  
  if not $(".container").hasClass "campaigns-dashboard"
    return
  
  new DatePicker ".campaigns-dashboard", (start, end, finished)->
    console.log arguments
    
  search = $(".display .search-box input")
  table = $(".display .table-body table").show().DataTable({
    "paging":   false
    "ordering": false
    "info":     false
    "search": false
    'columnDefs': [{
      'targets': 0,
      'checkboxes': {
        'selectRow': true
      }
    }]
    'order': [[1, 'asc']]
  })
  
  search.keyup ->
    table.column(1).search(search.val()).draw()