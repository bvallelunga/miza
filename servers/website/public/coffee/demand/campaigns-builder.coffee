class Dashboard

  $industry_options: []
  $selection_table: null
  $selection_empty: null

  constructor: ->
    @$total_budget = $(".quote-box .quote")
    @$input_budget = $(".budget-input input")
    @bind()
  
  bind: ->
    _this = @
  
    $(".range-display").each ->
      $(@).dateRangePicker({
        container: ".container .display"
        showShortcuts: false
        showTopbar: false
        autoClose: true
        singleDate : true
        singleMonth: true
        format: 'MM-DD-YYYY'
        startOfWeek: 'monday'
        language:'en'
        startDate: $(@).data("start-date")
        extraClass: "date-dropdown"
      })
      
    $(".is-house").change ->
      _this.update_budget()
      
    $(".pricing-input select").change ->
      $("placeholder").text $(this).val().toUpperCase()
      
    _this.$input_budget.on "keyup change", ->
      _this.update_budget()
 
        
  update_budget: ->
    BUDGET = if $(".is-house").val() == "true" then 0 else @$input_budget.val()
    @$total_budget.text numeral(BUDGET).format("$0,000.00")  
  

$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()