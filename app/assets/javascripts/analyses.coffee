style = (feature) ->
  color: "#007700"
  weight: 1
  opacity: 1
  fillColor: "#77ff77"
  fillOpacity: 0.4

onEachFeature = (feature, layer) ->
  popupContent = "<table>"
  for key of feature.properties
    popupContent += "<tr><th>" + key + "</th><td>" + feature.properties[key] + "<td></tr>"  unless key is "uri"
  popupContent += "</table>"
  popupContent += "<div><a href='" + feature.properties.uri + "' target='_blank'>Open in new tab</a></div>"  if feature.properties.aed_stratum
  layer.bindPopup popupContent

country_layer = `undefined`

map_country = (iso_code) ->
  $(".RM_country").hide()
  $("#country_" + iso_code).show()
  $.getJSON "/country/" + iso_code + "/map", (data) ->
    if country_layer
      map.removeLayer country_layer
    country_layer = L.geoJson(data,
      style: style
      onEachFeature: onEachFeature
    )
    country_layer.addTo map
    map.fitBounds country_layer.getBounds()

rc_selector = (element) ->
  element.parent().html "<select onchange=\"RM_rc_selected(this)\"><option>-</option><option>DA</option><option>DT</option><option>NG</option><option>NP</option><option>RS</option></select>"

window.RM_rc_selected = rc_selected = (element) ->
  $(element).parent().html element.value

status_activate = (element) ->
  element.closest('.RM_change').find('.RM_status_selector').each ->
    val = $(this).html()
    $(this).off 'click'
    $(this).html "<select><option>Needs review</option><option>In review</option><option>Reviewed</option></select>"
    $(this).find('select').each ->
      $(this).val(val)
      $(this).on 'change', ->
        status_changed($(this))
  element.closest('.RM_change').find('.RM_comments').each ->
    $(this).off 'click'
    $(this).html "<textarea onchange=\"RM_status_changed($(this))\">#{$(this).html()}</textarea>"
    $(this).find('textarea').each ->
      $(this).on 'keyup', (event) ->
        if event.which == 13
          status_changed($(this))
      $(this).on 'change', (event) ->
        status_changed($(this))

status_changed = (element) ->
  element.closest('.RM_change').each ->
    $(this).find('textarea').each ->
      val =  $(this).val()
      $(this).parent().each ->
        $(this).html val
        $(this).on 'click', ->
          status_activate $(this)
    $(this).find('select').each ->
      val = $(this).val()
      $(this).parent().each ->
        $(this).html val
        $(this).on 'click', ->
          status_activate $(this)

window.RM_comment_changed = comment_changed = (element) ->
  country = $(element).parent().parent()
  $(element).parent().html element.value
  country.find('.RM_status_selector').each ->
    $(this).parent().html $(this).value

highlight_stratum = (stratum) ->
  country_layer.eachLayer (l)->
    if l.feature.geometry.properties.aed_stratum == stratum
      l.setStyle
        fillColor: "#cccc00"
      map.fitBounds l.getBounds()
    else
      l.setStyle
        fillColor: "#007700"

hook_editing_events = ->
  $(".RM_country_name").each ->
    $(this).on 'click', ->
      map_country $(this).data('isocode')
  $(".RM_rc_selector").each ->
    $(this).on 'click', ->
      rc_selector $(this)
  $(".RM_status_selector").each ->
    $(this).on 'click', ->
      status_activate $(this)
  $(".RM_comments").each ->
    $(this).on 'click', ->
      status_activate $(this)
  $(".RM_stratum").each ->
    $(this).on 'click', ->
      highlight_stratum $(this).data('stratum'), $(this).data('year')

initialize_map = ->
  survey_map = new L.geoJson()
  L.control.scale(
    position: "bottomleft"
    metric: true
    imperial: false
  ).addTo map # map global defined by "map" helper

$ ->
  # Presence of #RM_map on page triggers the above
  $("#RM_map").each ->
    initialize_map()
    hook_editing_events()
