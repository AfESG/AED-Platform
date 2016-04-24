# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

RANGE_LAYER = null

getStyle = (p) ->
  fillColor = "#ffff00"
  rt = p['range_type']
  if rt is 'Non-range' or rt is 'Non range'
    fillColor="#222222"
  if rt is 'Doubtful'
    fillColor="#004400"
  if rt is 'Possible'
    fillColor="#009900"
  if rt is 'Known'
    fillColor="#00ff00"
  color = '#ffffff'
  weight = 0
  published_year = p['published_year']
  if published_year and published_year isnt ''
    if p.status is 'Needs review'
      color = '#ffff00'
      weight = 2
    if p.status is 'Keep as is'
      color = '#00ff00'
      weight = 2
    if p.status is 'Revert to 2007'
      color = '#ff0000'
      weight = 2
    if p.status is 'See comments'
      color = '#0000ff'
      weight = 2
  return {
    color: color
    weight: weight
    opacity: 1
    fillColor: fillColor
    fillOpacity: 0.4
  }

style = (feature) ->
  getStyle(feature.geometry.properties)

patch_change = (range_id, params, and_then) ->
  $.ajax({
    type: "PATCH"
    url: "/range_previews/#{range_id}.json"
    data:
      range_preview:
        params
    error: (data) ->
      console.log data
      alert "Error saving status and comments."
    success: (data) ->
      and_then() if and_then
  })

interact = (feature, layer) ->
  console.log "Interacting with feature"
  console.log feature
  p = feature.properties
  $('.RP_tables').html "
    <div><b>#{p.published_year}</b></div>
    <div><b>#{p.range_type}</b></div>
    <div>#{p.original_comments}</div>
    <select id='RP_status'>
    <option value='Needs review'>Needs review</option>
    <option value='Keep as is'>Keep as is</option>
    <option value='Revert to 2007'>Revert to 2007</option>
    <option value='See comments'>See comments</option>
    </select>
    <p>
    <div>Comments:</div>
    <textarea id='RP_comments'>#{p.comments || ''}</textarea>"
  console.log "Setting status to " + p.status
  $("#RP_status").val(p.status)
  $("#RP_status").on "change", ->
    feature.properties.status = $("#RP_status").val()
    patch_change feature.properties.range_id, {
      status: $("#RP_status").val()
    }, ->
      layer.setStyle(getStyle(feature.properties))

  $("#RP_comments").on "change", ->
    feature.properties.comments = $("#RP_comments").val()
    patch_change feature.properties.range_id,
      comments: $("#RP_comments").val()

onEachFeature = (feature, layer) ->
  published_year = feature.properties.published_year
  if published_year and published_year isnt ''
    layer.on
      click: ->
        interact(feature, layer)

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
