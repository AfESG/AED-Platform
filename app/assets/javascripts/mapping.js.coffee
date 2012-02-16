window.ft_initialize_below_protarea = (canvas_id, table_id, geometry_name, key_name, url_prefix, zoom, center, and_then) ->
  map = new google.maps.Map(document.getElementById(canvas_id),
    center: center
    zoom: zoom
    mapTypeId: google.maps.MapTypeId.TERRAIN
  )
  layer = new google.maps.FusionTablesLayer(
    query:
      select: geometry_name
      from: table_id
    map: map
    options:
      suppressInfoWindows: true
  )
  protarea = new google.maps.FusionTablesLayer(
    query:
      select: 'geometry'
      from: 2898400
    map: map
  )
  infoWindow = new google.maps.InfoWindow()
  google.maps.event.addListener layer, "click", (e) ->
    infoWindow.setContent "Loading " + e.row[key_name].value
    infoWindow.setPosition e.latLng
    infoWindow.open map
    jQuery.get url_prefix + e.row[key_name].value, (data) ->
      infoWindow.setContent data
  and_then()

window.ft_initialize = (canvas_id, table_id, geometry_name, key_name, url_prefix, zoom, center, and_then) ->
  map = new google.maps.Map(document.getElementById(canvas_id),
    center: center
    zoom: zoom
    mapTypeId: google.maps.MapTypeId.TERRAIN
  )
  protarea = new google.maps.FusionTablesLayer(
    query:
      select: 'geometry'
      from: 2898400
    map: map
  )
  layer = new google.maps.FusionTablesLayer(
    query:
      select: geometry_name
      from: table_id
    map: map
    options:
      suppressInfoWindows: true
  )
  infoWindow = new google.maps.InfoWindow()
  google.maps.event.addListener layer, "click", (e) ->
    infoWindow.setContent "Loading " + e.row[key_name].value
    infoWindow.setPosition e.latLng
    infoWindow.open map
    jQuery.get url_prefix + e.row[key_name].value, (data) ->
      infoWindow.setContent data
  and_then()

window.map = undefined

