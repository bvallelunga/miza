$ ->
  $(".template").each ->
    $template = $(this)
    template = $template.data "template"
    
    $.get("/admin/emails/#{template}").done (response)->
      $template.find(".subject").html response.subject
      $template.find(".body").html response.body