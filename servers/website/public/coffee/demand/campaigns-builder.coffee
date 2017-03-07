class Dashboard

  $industry_options: []
  $impressions_table: null
  $impressions_empty: null
  $simulator: null

  constructor: ->
    @$industry_options = $(".selection .option")
    @$impressions_table = $(".impressions_table")
    @$impressions_empty = $(".impressions_empty")
    @$simulator = $(".simulator")
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
      
    _this.$industry_options.click ->
      _this.option_selected $(@)
      
     
    $(".selection-shortcut").click ->
      _this.option_selected _this.$industry_options, true
    
    @$impressions_table.find("select").change ->
      _this.impressions_updated $(@)
      
    uploadcare.Widget('[role=uploadcare-uploader]').onChange (file)->
      _this.simulator_update()
      
    uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete (file)->
      _this.simulator_update()
      
    $(".simulator-watch").on "keyup", ->
       _this.simulator_update()
  
  
  simulator_update: ->
    img = $(".simulator-image").val()
    text = $(".simulator-description").val()
      .replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;')
      .replace(/</g, '&lt;')
      .replace(/\n/g, '<br>')
  
    @$simulator.find("strong").toggle (text or img) == ""
    @$simulator.find("a").attr "href", $(".simulator-link").val() or "#"
    @$simulator.find("div").html(text).toggle(text.length > 0)
    @$simulator.find("img").attr("src", img).toggle(img.length > 0)
  
  
  total_cost_update: ->
    total = 0
    
    $(".selection .option.active").each ->
      $industry = $("#industry_#{$(@).data("value")}")
      CPM = Number $industry.data("cpm")
      IMPRESSIONS = Number $industry.find("select").val()
      total += CPM * (IMPRESSIONS/1000)
      $(".quote-box .quote").text numeral(total).format("$0,000.00")     

  
  impressions_updated: ($select)->
    $tr = $select.parents("tr")
    CPM = Number $tr.data("cpm")
    IMPRESSIONS = Number $select.val()
    COST = CPM * (IMPRESSIONS/1000)
    $tr.find(".total").text numeral(COST).format("$0,000.00")
    @total_cost_update()
  
  
  option_selected: ($options, force=null)->
    $options.toggleClass "active", force
    show_table = @$industry_options.filter(".active").length > 0
    @$impressions_table.toggle show_table
    @$impressions_empty.toggle not show_table
    
    $(".selection .option").each ->
      $option = $(@)
      value = $option.hasClass("active")
      $industry = $("#industry_#{$option.data("value")}")
      $industry.toggle value
      $industry.find(".activated_input").val value
      $industry.find("select").attr "required", value
      
    @total_cost_update()


$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()