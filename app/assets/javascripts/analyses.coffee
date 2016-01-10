style = (feature) ->
  color: "#007700"
  weight: 1
  opacity: 1
  fillColor: "#77ff77"
  fillOpacity: 0.6

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
  element.parent().html "<select onchange=\"rc_selected(this)\"><option>-</option><option>DA</option><option>DT</option><option>NG</option><option>NP</option><option>RS</option></select>"

rc_selected = (element) ->
  element.parent().html element.value

status_selector = (element) ->
  element.parent().html "<select onchange=\"status_selected(this)\"><option>Needs review</option><option>In review</option><option>Reviewed</option></select><textarea>Comments</textarea>"

status_selected = (element) ->
  element.parent().html element.value

highlight_stratum = (stratum) ->
  country_layer.eachLayer (l)->
    if l.feature.geometry.properties.aed_stratum == stratum
      console.log 'found, setting feature style'
      l.setStyle
        color: "#777700"
      map.fitBounds l.getBounds()
    else
      l.setStyle
        color: "#007700"

hook_editing_events = ->
  $(".RM_country_name").each ->
    $(this).on 'click', ->
      map_country $(this).data('isocode')
  $(".RM_rc_selector").each ->
    $(this).on 'click', ->
      rc_selector $(this)
  $(".RM_status_selector").each ->
    $(this).on 'click', ->
      status_selector $(this)
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
