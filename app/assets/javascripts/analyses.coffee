ACTIVE_STRATA_CELL = null
COUNTRY_LAYER = null

strip_for = (map_props) ->
  html = "<div>#{map_props.aed_year} #{map_props.aed_name}</div>"
  html += "<div style='font-size: x-small'>#{map_props.aed_citation}</div>"
  html += "<div style='font-size: x-small'><a href='#{map_props.uri}' target='_blank'>#{map_props.aed_stratum}</a> est. #{map_props.aed_estimate}, #{map_props.aed_area} km²</div>"

style = (feature) ->
  color="#77ff77"
  if RM_used_estimates[feature.geometry.properties['aed_stratum']]
    color="#ff7777"
  return {
    color: "#007700"
    weight: 1
    opacity: 1
    fillColor: color
    fillOpacity: 0.4
  }

onEachFeature = (feature, layer) ->
  popupContent = strip_for feature.properties
  popupContent += "<div style='margin-top: 5px;'><a href='javascript:add_stratum(\""+feature.properties.aed_stratum+"\")'>Add this stratum</a></div>"  if feature.properties.aed_stratum
  layer.bindPopup popupContent

map_country = (element) ->
  country_element = $(element).closest('.RM_country')
  iso_code = country_element.data('isocode')
  $(".RM_changes, .RM_other_header, .RM_new_change").hide()
  country_element.find(".RM_changes, .RM_other_header, .RM_new_change").show()
  $.getJSON "/country/" + iso_code + "/map", (data) ->
    if COUNTRY_LAYER
      map.removeLayer COUNTRY_LAYER
    COUNTRY_LAYER = L.geoJson(data,
      style: style
      onEachFeature: onEachFeature
    )
    COUNTRY_LAYER.addTo map
    map.fitBounds COUNTRY_LAYER.getBounds()

patch_change = (change_id, params, and_then) ->
  $.ajax({
    type: "PATCH"
    url: "/changes/#{change_id}.json"
    data:
      change:
        params
    error: (data) ->
      console.log data
      alert "Error saving status and comments."
    success: (data) ->
      and_then() if and_then
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
      $(this).on 'blur', (event) ->
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

remove_stratum = (element) ->
  stratum_element = $(element).closest(".RM_stratum")
  input_zone_id = stratum_element.data('stratum')
  strata_element = stratum_element.closest(".RM_strata")
  key = 'new_strata'
  value = strata_element.data "newstrata"
  unless value
    key = 'replaced_strata'
    value = strata_element.data "replacedstrata"
  values = value.split(/,\s*/)
  new_values = []
  for v in values
    new_values.push v if v isnt input_zone_id
  value = new_values.join ','
  if value == ''
    value = '-'
  props = {}
  props[key] = value
  if key == 'new_strata'
    strata_element.data "newstrata", value
  else
    strata_element.data "replacedstrata", value
  change_element = strata_element.closest(".RM_change")
  change_id = change_element.data 'changeid'
  stratum_element.remove()
  if strata_element.html() == ''
    strata_element.html('-')
  patch_change change_id, props, ->
    COUNTRY_LAYER.eachLayer (l)->
      if l.feature.geometry.properties.aed_stratum == input_zone_id
        l.setStyle
          fillColor: "#77ff77"
        map.fitBounds l.getBounds()
      else
        l.setStyle style(l.feature)

# Bind to window to facilitate calling from Leaflet popup
window.add_stratum = add_stratum = (stratum_id) ->
  unless ACTIVE_STRATA_CELL
    alert "Please select a new or replaced strata cell first."
  strata_element = $(ACTIVE_STRATA_CELL)
  key = 'new_strata'
  value = strata_element.data "newstrata"
  unless value
    key = 'replaced_strata'
    value = strata_element.data "replacedstrata"
  values = []
  if value != '-'
    values = value.split(/,\s*/)
  values.push stratum_id
  value = values.join ','
  props = {}
  props[key] = value
  if key == 'new_strata'
    strata_element.data "newstrata", value
  else
    strata_element.data "replacedstrata", value
  change_element = strata_element.closest(".RM_change")
  change_id = change_element.data 'changeid'
  patch_change change_id, props, ->
    COUNTRY_LAYER.eachLayer (l)->
      if l.feature.geometry.properties.aed_stratum == stratum_id
        map_props = l.feature.geometry.properties
        html = "<div class='RM_stratum' data-stratum='#{map_props.aed_stratum}' data-year='#{map_props.aed_year}'>"
        html += strip_for map_props
        html += "</div>"
        if strata_element.html() == '-'
          strata_element.html('')
        strata_element.append html
        strata_element.find(".RM_stratum").on 'click', ->
          highlight_stratum this

highlight_stratum = (element) ->
  stratum_element = $(element)
  $('.RM_stratum').css { backgroundColor: '' }
  $('.RM_remove_stratum_container').remove()
  stratum_element.css { backgroundColor: '#ffff77' }
  stratum_element.append( '<div class="RM_remove_stratum_container"><div class="RM_remove_stratum pull-right btn btn-xs btn-danger"><span class="glyphicon glyphicon-remove"></span> Remove</div>&#160;</div>')
  stratum_element.find('.RM_remove_stratum').on 'click', ->
    remove_stratum this
  stratum = stratum_element.data('stratum')
  year = stratum_element.data('year')
  COUNTRY_LAYER.eachLayer (l)->
    if l.feature.geometry.properties.aed_stratum == stratum
      l.setStyle
        fillColor: "#ffff77"
      map.fitBounds l.getBounds()
    else
      l.setStyle style(l.feature)

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
      country_element.find('.RM_changes').each ->
        $(this).append($('.RM_template_change').html())
        change = $(this).find('.RM_change').last()
        $(change).data "changeid", data.id
        hook_change_editing_events change
    error: (data) ->
      console.log data
      alert "Error adding input zone."
  })

activate_adding_strata = (element) ->
  ACTIVE_STRATA_CELL = element
  $(".RM_strata").css {
    border: 'none';
  }
  $(element).css {
    border: '3px solid #cccccc'
  }

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
    highlight_stratum this
  change.find(".RM_strata").on 'click', ->
    activate_adding_strata this

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
