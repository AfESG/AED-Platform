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

map_country = (element) ->
  country_element = $(element).closest('.RM_country')
  iso_code = country_element.data('isocode')
  $(".RM_changes, .RM_other_header, .RM_new_change").hide()
  country_element.find(".RM_changes, .RM_other_header, .RM_new_change").show()
  $.getJSON "/country/" + iso_code + "/map", (data) ->
    if country_layer
      map.removeLayer country_layer
    country_layer = L.geoJson(data,
      style: style
      onEachFeature: onEachFeature
    )
    country_layer.addTo map
    map.fitBounds country_layer.getBounds()

patch_change = (change_id, params) ->
  $.ajax({
    type: "PATCH"
    url: "/changes/#{change_id}.json"
    data:
      change:
        params
    error: (data) ->
      console.log data
      alert "Error saving status and comments."
  })

rc_activate = (element) ->
  $(element).closest('.RM_change').find('.RM_rc_selector').each ->
    $(this).off 'click'
    val = $(this).html()
    $(this).html  "<select><option>-</option><option>DA</option><option>DT</option><option>NG</option><option>NP</option><option>RS</option></select>"
    $(this).find('select').each ->
      $(this).val(val)
      $(this).on 'change', ->
        rc_changed(this)

rc_changed = (element) ->
  $(element).closest('.RM_change').each ->
    change_id = $(this).data 'changeid'
    val = ''
    $(this).find('.RM_rc_selector').each ->
      $(this).find('select').each ->
        val = $(this).val()
        $(this).parent().each ->
          $(this).html val
          $(this).on 'click', ->
            rc_activate this
    patch_change change_id,
      reason_change: val

name_activate = (element) ->
  $(element).closest('.RM_change').find('.RM_replacement_name').each ->
    $(this).off 'click'
    val = $(this).html()
    $(this).html "<input type='text'>"
    $(this).find('input').each ->
      $(this).val(val)
      $(this).on 'change', ->
        name_changed(this)
      $(this).on 'keyup', (event) ->
        if event.which == 13
          name_changed(this)
      $(this).focus()

name_changed = (element) ->
  $(element).closest('.RM_change').each ->
    change_id = $(this).data 'changeid'
    val = ''
    $(this).find('.RM_replacement_name').each ->
      $(this).find('input').each ->
        val = $(this).val()
        $(this).parent().each ->
          $(this).html val
          $(this).on 'click', ->
            name_activate this
    patch_change change_id,
      replacement_name: val

status_activate = (element) ->
  $(element).closest('.RM_change').find('.RM_status_selector').each ->
    val = $(this).html()
    $(this).off 'click'
    $(this).html "<select><option>Needs review</option><option>In review</option><option>Reviewed</option></select>"
    $(this).find('select').each ->
      $(this).val(val)
      $(this).on 'change', ->
        status_changed(this)
  $(element).closest('.RM_change').find('.RM_comments').each ->
    $(this).off 'click'
    $(this).html "<textarea>#{$(this).html()}</textarea>"
    $(this).find('textarea').each ->
      $(this).on 'keyup', (event) ->
        if event.which == 13
          status_changed(this)
      $(this).on 'change', (event) ->
        status_changed(this)

status_changed = (element) ->
  $(element).closest('.RM_change').each ->
    change_id = $(this).data 'changeid'
    status_val = ''
    comments_val = ''
    $(this).find('textarea').each ->
      comments_val =  $(this).val()
      $(this).parent().each ->
        $(this).html comments_val
        $(this).on 'click', ->
          status_activate this
    $(this).find('select').each ->
      status_val = $(this).val()
      $(this).parent().each ->
        $(this).html status_val
        $(this).on 'click', ->
          status_activate this
    patch_change change_id,
      status: status_val
      comments: comments_val

highlight_stratum = (stratum) ->
  country_layer.eachLayer (l)->
    if l.feature.geometry.properties.aed_stratum == stratum
      l.setStyle
        fillColor: "#cccc00"
      map.fitBounds l.getBounds()
    else
      l.setStyle
        fillColor: "#007700"

add_new_change = (element) ->
  country_element = $(element).closest('.RM_country')
  iso_code = country_element.data('isocode')
  analysis_name = $('.RM_context').data('analysisname')
  analysis_year = $('.RM_context').data('analysisyear')
  $.ajax({
    type: "POST"
    url: "/changes.json"
    data:
      change:
        analysis_name: analysis_name
        analysis_year: analysis_year
        reason_change: '-'
        status: 'Needs review'
        country: iso_code
    success: (data) ->
      console.log data
      country_element.find('.RM_changes').each ->
        $(this).append($('.RM_template_change').html())
        change = $(this).find('.RM_change').last()
        $(change).data "changeid", data.id
        hook_change_editing_events change
    error: (data) ->
      console.log data
      alert "Error adding input zone."
  })


hook_change_editing_events = (element) ->
  change = $(element)
  change.find(".RM_rc_selector").on 'click', ->
    rc_activate this
  change.find(".RM_status_selector").on 'click', ->
    status_activate this
  change.find(".RM_comments").on 'click', ->
    status_activate this
  change.find(".RM_replacement_name").on 'click', ->
    name_activate this
  change.find(".RM_stratum").on 'click', ->
    highlight_stratum $(this).data('stratum'), $(this).data('year')

hook_editing_events = ->
  $(".RM_country_indicator").on 'click', ->
    map_country this
  $(".RM_change").each ->
    hook_change_editing_events this
  $(".RM_new_change_button").on 'click', ->
    add_new_change this

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
