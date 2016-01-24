map = null
MAP_INITIALIZED = false
COUNTRY_LAYER = null

strip_for = (map_props) ->
  html = "<div>#{map_props.aed_year} #{map_props.aed_name}</div>"
  html += "<div style='font-size: x-small'>#{map_props.aed_citation}</div>"
  html += "<div style='font-size: x-small'><a href='#{map_props.uri}' target='_blank'>#{map_props.aed_stratum}</a> est. #{map_props.aed_estimate}, #{map_props.aed_area} km²</div>"

style = (feature) ->
  return {
    color: "#007700"
    weight: 1
    opacity: 1
    fillColor: "#77ff77"
    fillOpacity: 0.4
  }

onEachFeature = (feature, layer) ->
  popupContent = strip_for feature.properties
  layer.bindPopup popupContent

initialize_map = (map_uri)->

  console.log "Initializing map with #{map_uri}"

  # This work duplicates the map helper used elsewhere, but
  # in this case we need to do it in a deferred fashion so the
  # map helper won't get it done for us.
  map = L.map('CM_map')

  map.setView([-12.04, 18.59], 4)
  L.tileLayer('http://otile2.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png', {
            attribution: 'AfESG',
            maxZoom: 18,
  subdomains: '',
  }).addTo(map)

  survey_map = new L.geoJson()
  L.control.scale(
    position: "bottomleft"
    metric: true
    imperial: false
  ).addTo map

  $.getJSON "/country/survey_map/" + map_uri + "/", (data) ->
    if COUNTRY_LAYER
      map.removeLayer COUNTRY_LAYER
    COUNTRY_LAYER = L.geoJson(data,
      style: style
      onEachFeature: onEachFeature
    )
    COUNTRY_LAYER.addTo map
    map.fitBounds COUNTRY_LAYER.getBounds()

  MAP_INITIALIZED = true

window.load_country_map = (map_uri) ->
  initialize_map(map_uri) unless MAP_INITIALIZED

$ ->
  $(".CM_context").each ->
    target = $(this).data('target')
    map_uri = $(this).data('mapuri')
    $("a[href=\"#{target}\"]").on 'shown.bs.tab', ->
      $('.below_tabs').hide()
      load_country_map(map_uri)
    $("a[href=\"#{target}\"]").on 'hidden.bs.tab', ->
      $('.below_tabs').show()
