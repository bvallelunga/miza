class Dashboard
  
  $iframe: {}  

  constructor: ->
    @$total_budget = $(".quote-box .quote")
    @$input_budget = $(".budget-input input")
    @bind()
  
  bind: ->
    _this = @
  
    $(".range-display").each ->
      $(@).dateRangePicker({
        container: $(@).parents(".display")
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
      
    $('.bid-selector input[type=radio][name=bid_type]').change ->
      $(".bid-input").toggle this.value == "manual"
      
    $(".is-house").change ->
      _this.update_budget()
      
    
    $(".targeting-select").click ->
      $(".targeting-hide").show()
      $(@).hide()
      $(".chosen-select").chosen({
        inherit_select_classes: true
      })
      
    $(".pricing-input select").change ->
      $("placeholder").text $(this).val().toUpperCase()
      
    _this.$input_budget.on "keyup change", ->
      _this.update_budget()
 
  
  update_scrape: (response)->  
    _this = @

    $(".scrape-done").show()
    $(".image-list").toggle response.image_selection
    $(".creative-images").remove()
    $(".creative-link").val response.link
    $(".creative-format").val response.format
    $(".creative-config").val JSON.stringify response.config
    
    @iframe = {
      link: response.link
      config: response.config
      format: response.format
    }
    @update_iframe()
    
    if response.image_selection
      $images = response.images.map (url, i)->
        $image = $("""
          <div class="image" data-id="image_#{i}" style="background-image:url(#{url})" data-url="#{url}">
            <div class="hover fa fa-check"></div>
          </div>
        """)
        
        $image.click ->
          to_active = not $image.hasClass "active"

          if to_active and $(".image-list .active").length < 4
            $image.addClass "active"
            
          if not to_active
            $image.removeClass "active"
            
          _this.iframe.config.images = ($(".image-list .image.active").map -> $(@).data("url")).toArray()
          $(".creative-config").val JSON.stringify _this.iframe.config
          _this.update_iframe()
          
        return $image
        
      $(".image-list .list").html $images      
      
        
  update_budget: ->
    BUDGET = if $(".is-house").val() == "true" then 0 else @$input_budget.val()
    @$total_budget.text numeral(BUDGET).format("$0,000.00")  
    
  
  update_iframe: ->
    $iframe = $(".simulator-iframe")
    
    if @iframe.config.images.length > 0
      $iframe.attr("src", "#{$iframe.data("base-src")}&#{$.param(@iframe)}")
    else
      $iframe.attr("src", "").hide()
  

$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()
  window.campaign_scrape = dashboard.update_scrape.bind(dashboard)