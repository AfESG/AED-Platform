# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

RANGE_LAYER = null

style = (feature) ->
  fillColor = "#ffff00"
  rt = feature.geometry.properties['range_type']
  if rt is 'Non-range' or rt is 'Non range'
    fillColor="#333333"
  if rt is 'Doubtful'
    fillColor="#007700"
  if rt is 'Possible'
    fillColor="#00cc00"
  if rt is 'Known'
    fillColor="#00ff00"
  color = '#ffffff'
  weight = 0
  published_year = feature.geometry.properties['published_year']
  if published_year and published_year isnt ''
    color = '#ffff00'
    weight = 2
  return {
    color: color
    weight: weight
    opacity: 1
    fillColor: fillColor
    fillOpacity: 0.4
  }

onEachFeature = (feature, layer) ->
  published_year = feature.properties['published_year']
  if published_year and published_year isnt ''
    popupContent = "<div><b>#{feature.properties['published_year']}</b></div>"
    popupContent += "<div>#{feature.properties['original_comments']}</div>"
    popupContent += "<div><b>#{feature.properties['status']}</b></div>"
    layer.bindPopup popupContent

$ ->
  console.log('Looking for range preview map')
  $("#RP_map").each ->
    console.log('Range preview map found, loading')
    $(".RP_FS_loading").show()
    $.getJSON "/range_preview_map", (data) ->
      RANGE_LAYER = L.geoJson(data,
        style: style
        onEachFeature: onEachFeature
      )
      RANGE_LAYER.addTo map

      $(".RP_FS_loading").hide()
