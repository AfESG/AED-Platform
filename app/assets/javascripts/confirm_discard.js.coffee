jQuery(document).ready ($) ->
  $("form").on "change", "input, select, textarea", ->
    $(this).closest("form").data "data-changed", true

  $("form").on "submit", ->
    $(this).closest("form").data "data-changed", false

  $(window).bind "beforeunload", ->
    foundChange = false
    $("form").each ->
      foundChange = true  if $(this).data("data-changed")

    "If you proceed, your changes will be lost"  if foundChange
