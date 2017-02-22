$ ->

  $(".company_list").on "keyup", ".company-search", ->
    value = $(@).val()
    
    $(".company_list .company-link").each ->
      item = $(@)
      name = item.text().toLowerCase()
      item.toggle name.indexOf(value) > -1