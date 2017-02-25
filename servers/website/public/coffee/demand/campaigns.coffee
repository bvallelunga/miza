$ ->
  
  if not $(".container").hasClass "campaigns-dashboard"
    return
  
  new DatePicker ".campaigns-dashboard", (start, end, finished)->
    console.log arguments
    
  table = $(".display .table-body table").DataTable({
    bFilter: false
    "paging":   false
    "ordering": false
    "info":     false
    'columnDefs': [{
      'targets': 0,
      'checkboxes': {
        'selectRow': true
      }
    }],
    'select': {
      'style': 'multi'
    }
    'order': [[1, 'asc']]
  })