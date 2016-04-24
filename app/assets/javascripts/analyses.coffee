ACTIVE_STRATA_CELL = null
COUNTRY_LAYER = null

COMMIT_ACTIVE_CELL = null

prepare_commit_function = (f) ->
  console.log("Prepare commit function #{f}")
  COMMIT_ACTIVE_CELL = f

commit_active_cell = ->
  if COMMIT_ACTIVE_CELL
    f = COMMIT_ACTIVE_CELL
    COMMIT_ACTIVE_CELL = null
    console.log("Execute commit function #{f}")
    f()

ifdef = (s) ->
  return s if s
  ''

strip_for = (map_props) ->
  html = "<div>#{map_props.aed_year} #{ifdef(map_props.aed_name)} #{ifdef(map_props.aed_internal_name)}</div>"
  html += "<div style='font-size: x-small'>#{ifdef(map_props.aed_citation)}</div>"
  html += "<div style='font-size: x-small'><a href='#{map_props.uri}' target='_blank'>#{map_props.aed_stratum}</a> est. #{map_props.aed_estimate}, #{map_props.aed_area} km²</div>"

add_link_for = (map_props) ->
  if map_props.aed_stratum
    "<div style='margin-top: 5px;'><a href='javascript:add_stratum(\""+map_props.aed_stratum+"\")'>Add this stratum</a></div>"
  else
    ""

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
  map_props = feature.properties
  popupContent = strip_for(map_props)
  unless RM_used_estimates[map_props['aed_stratum']]
    popupContent += add_link_for(map_props)
  layer.bindPopup popupContent

map_country = (element) ->
  country_element = $(element).closest('.RM_country')
  iso_code = country_element.data('isocode')
  $(".RM_FS_loading").show()
  $.getJSON "/country/" + iso_code + "/map", (data) ->
    $(".RM_changes, .RM_other_header, .RM_new_change").hide()
    country_element.find(".RM_changes, .RM_other_header, .RM_new_change").show()
    if COUNTRY_LAYER
      map.removeLayer COUNTRY_LAYER
    COUNTRY_LAYER = L.geoJson(data,
      style: style
      onEachFeature: onEachFeature
    )
    COUNTRY_LAYER.addTo map
    try
      map.fitBounds COUNTRY_LAYER.getBounds()
      $(".RM_FS_loading").hide()
    catch
      $(".RM_FS_loading").hide()
      $(".RM_changes, .RM_other_header, .RM_new_change").hide()
      alert "No survey data found for country code #{iso_code}"

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
      mark_removal_eligible_changes()
  })

no_replacement = (element) ->
  new_strata = $(element).closest('.RM_change').find('.RM_new_strata').first()
  n = new_strata.data("newstrata")
  if n == "" or n == "-"
    return true
  return false

copy_replaced_to_new = (change) ->
  new_strata = change.find('.RM_new_strata').first()
  replaced_strata = change.find('.RM_replaced_strata').first()
  new_strata.html(replaced_strata.html())
  rsid = replaced_strata.data("replacedstrata")
  new_strata.data("newstrata",rsid)
  hook_change_editing_events(change)

rc_activate = (element) ->
  commit_active_cell()
  $(element).closest('.RM_change').find('.RM_rc_selector').each ->
    $(this).off 'click'
    val = $(this).html()
    nc_option = ""
    if val=="NC" or no_replacement(element)
      nc_option="<option>NC</option>"
    $(this).html  "<select><option>-</option><option>DA</option><option>DT</option><option>NG</option><option>NP</option><option>PL</option><option>RS</option>#{nc_option}</select>"
    $(this).find('select').each ->
      $(this).val(val)
      $(this).on 'change', ->
        commit_active_cell()
      prepare_commit_function ->
        rc_changed(element)

rc_changed = (element) ->
  change = $(element).closest('.RM_change').first()
  change_id = change.data 'changeid'
  val = ''
  change.find('.RM_rc_selector').each ->
    $(this).find('select').each ->
      val = $(this).val()
      $(this).parent().each ->
        $(this).html val
        $(this).on 'click', ->
          rc_activate this
  params =
    reason_change: val
  patch_change change_id, params, ->
    console.log(val)
    if val == 'NC'
      copy_replaced_to_new(change)

name_activate = (element) ->
  commit_active_cell()
  $(element).closest('.RM_change').each ->
    $(this).find('.RM_population').each ->
      $(this).off 'click'
      val = $(this).html()
      $(this).html "Population:<br/><input type='text'>"
      $(this).find('input').each ->
        $(this).val(val)
        $(this).on 'change', ->
          commit_active_cell()
        $(this).on 'keyup', (event) ->
          if event.which == 13
            commit_active_cell()
        $(this).on 'blur', (event) ->
          commit_active_cell()
    $(this).find('.RM_replacement_name').each ->
      $(this).off 'click'
      val = $(this).html()
      $(this).html "Input Zone:<br/><input type='text'>"
      $(this).find('input').each ->
        $(this).val(val)
        $(this).on 'change', ->
          commit_active_cell()
        $(this).on 'keyup', (event) ->
          if event.which == 13
            commit_active_cell()
        $(this).on 'blur', (event) ->
          commit_active_cell()
    prepare_commit_function ->
      name_changed(element)

name_changed = (element) ->
  $(element).closest('.RM_change').each ->
    change_id = $(this).data 'changeid'
    replacement_name = ''
    population = ''
    $(this).find('.RM_replacement_name').each ->
      $(this).find('input').each ->
        replacement_name = $(this).val()
        $(this).parent().each ->
          $(this).html replacement_name
          $(this).on 'click', ->
            name_activate this
    $(this).find('.RM_population').each ->
      $(this).find('input').each ->
        population = $(this).val()
        $(this).parent().each ->
          $(this).html population
          $(this).on 'click', ->
            name_activate this
    patch_change change_id,
      population: population,
      replacement_name: replacement_name

status_activate = (element) ->
  commit_active_cell()
  change = $(element).closest('.RM_change').first()
  window.reveal_history('Change',change.data('changeid'))
  change.find('.RM_status_selector').each ->
    val = $(this).html()
    $(this).off 'click'
    completed_available = ''
    if val == 'Reviewed' or val == 'Completed'
      completed_available = "<option>Completed</option>"
    $(this).html "<select><option>Needs review</option><option>In review</option><option>Reviewed</option>#{completed_available}</select>"
    $(this).find('select').each ->
      $(this).val(val)
      $(this).data('initial_index', $(this).prop("selectedIndex"))
      $(this).on 'change', ->
        commit_active_cell()
  change.find('.RM_comments').each ->
    $(this).off 'click'
    $(this).html "<textarea>#{$(this).html()}</textarea>"
    $(this).find('textarea').each ->
      $(this).on 'keyup', (event) ->
        if event.which == 13
          commit_active_cell()
      $(this).on 'change', (event) ->
        commit_active_cell()
  prepare_commit_function ->
    status_changed(element)

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
      current_index = $(this).prop('selectedIndex')
      initial_index = $(this).data('initial_index')
      console.log("Status val was #{initial_index} and will be #{current_index}")
      if (current_index < initial_index)
        unless confirm("Are you sure you want to go backwards to status \"#{status_val}?\"")
          $(this).find('option').eq(initial_index).prop('selected',true)
          status_val = $(this).val()
      $(this).parent().each ->
        $(this).html status_val
        $(this).on 'click', ->
          status_activate this
    window.hide_history_window()
    patch_change change_id,
      status: status_val
      comments: comments_val

remove_stratum = (element) ->
  map.closePopup()
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
        # Make feature green and selectable
        map_props = l.feature.geometry.properties
        console.log l
        l.bindPopup(strip_for(map_props) + add_link_for(map_props))
        l.setStyle
          fillColor: "#77ff77"
        map.fitBounds l.getBounds()
      else
        l.setStyle style(l.feature)

# Bind to window to facilitate calling from Leaflet popup
window.add_stratum = add_stratum = (stratum_id) ->
  unless ACTIVE_STRATA_CELL
    alert "Please select a new or replaced strata cell first."
  map.closePopup()
  strata_element = $(ACTIVE_STRATA_CELL)
  key = 'new_strata'
  value = strata_element.data "newstrata"
  unless value
    key = 'replaced_strata'
    value = strata_element.data "replacedstrata"
  values = []
  if value and (value != '-')
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
        html += strip_for(map_props)
        html += "</div>"
        # Make feature red and not selectable
        console.log l
        l.bindPopup(strip_for(map_props))
        l.setStyle
          fillColor: "#ff7777"
        if strata_element.html() == '-'
          strata_element.html('')
        strata_element.append html
        strata_element.find(".RM_stratum").on 'click', ->
          highlight_stratum this

highlight_stratum = (element) ->
  commit_active_cell()
  stratum_element = $(element)
  $('.RM_stratum').css { backgroundColor: '' }
  $('.RM_remove_stratum_container').remove()
  stratum_element.css { backgroundColor: '#ffff77' }
  stratum_element.append( '<div class="RM_remove_stratum_container"><div class="RM_remove_stratum pull-right btn btn-xs btn-danger"><span class="glyphicon glyphicon-remove"></span> Remove</div>&#160;</div>')
  stratum_element.find('.RM_remove_stratum').on 'click', ->
    remove_stratum this
  stratum = stratum_element.data('stratum')
  year = stratum_element.data('year')
  feature_found = false
  COUNTRY_LAYER.eachLayer (l)->
    if l.feature.geometry.properties.aed_stratum == stratum
      l.setStyle
        fillColor: "#ffff77"
      map.fitBounds l.getBounds()
      feature_found = true
    else
      l.setStyle style(l.feature)
  unless feature_found
    alert "Corresponding feature not found on map"

mark_removal_eligible_changes = () ->
  $('.RM_change').each ->
    found = false
    $(this).find('.RM_stratum').each ->
      found = true
    unless found
      $(this).find('.RM_remove_change').remove()
      $(this).find('.RM_replacement_name').parent().append('<div class="RM_remove_change_wrapper"><div class="RM_remove_change pull-right btn btn-xs btn-danger"><span class="glyphicon glyphicon-remove"></span> Remove</div>&#160;</div>')
      hook_change_editing_events $(this)

remove_change = (element) ->
  change = $(element).closest('.RM_change')
  changeid = change.data('changeid')
  $.ajax({
    type: "DELETE"
    url: "/changes/#{changeid}"
    dataType: 'json'
    data:
      change:
        id: changeid
    success: (data) ->
      change.remove()
    error: (data) ->
      console.log data
      alert "Error removing input zone."
  })

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
  commit_active_cell()
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
  change.find(".RM_population").on 'click', ->
    name_activate this
  change.find(".RM_stratum").on 'click', ->
    highlight_stratum this
  change.find(".RM_strata").on 'click', ->
    activate_adding_strata this
  change.find(".RM_remove_change").on 'click', ->
    remove_change this

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
    mark_removal_eligible_changes()
