$ ->
  $(".template").each ->
    $template = $(this)
    template = $template.data "template"
    
    $.get("/admin/emails/#{template}").done (response)->
      $template.html response