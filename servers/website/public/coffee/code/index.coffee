$ ->
  $('pre code:not(.ignore)').each (i, block)->
    hljs.highlightBlock(block)