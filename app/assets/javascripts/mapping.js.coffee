window.map_initialize = (canvas_id, and_then) ->
  myOptions =
    zoom: 4
    mapTypeId: google.maps.MapTypeId.TERRAIN
    streetViewControl: false
  window.map = new google.maps.Map(document.getElementById(canvas_id), myOptions)
  window.map.setCenter new google.maps.LatLng(0, 0)
  and_then()

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
  window.map = map
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
  window.map = map
  and_then()

window.markMap = (marker, url, lat, lng) ->
  marker = new google.maps.Marker(
    icon: new google.maps.MarkerImage(marker)
    position: new google.maps.LatLng(lat, lng)
    url: url
    map: map
  )
  google.maps.event.addListener marker, 'click', (e) ->
    window.location.href = url

window.addExistingZone = (population_submission_id, lat, lng) ->
  lat = 0 if lat == ''
  lng = 0 if lng == ''
  myLocation = new google.maps.LatLng(lat, lng)
  user_draggable = false
  if document.getElementById("population_submission_latitude")
    user_draggable = true
  marker = new google.maps.Marker(
    icon: new google.maps.MarkerImage('http://www.google.com/intl/en_us/mapfiles/ms/micons/orange.png')
    position: new google.maps.LatLng(lat, lng)
    title: "Input Zone #" + population_submission_id
    population_submission_id: population_submission_id
    map: map
    draggable: user_draggable
  )
  window.map.setCenter myLocation
  if user_draggable
    google.maps.event.addListener marker, "dragend", ->
      document.getElementById("population_submission_latitude").value = marker.getPosition().lat()
      document.getElementById("population_submission_longitude").value = marker.getPosition().lng()
  jQuery('#population_submission_latitude').change ->
    marker.setPosition(new google.maps.LatLng(this.value,marker.getPosition().lng()))
    map.setCenter marker.getPosition()
  jQuery('#population_submission_longitude').change ->
    marker.setPosition(new google.maps.LatLng(marker.getPosition().lat(),this.value))
    map.setCenter marker.getPosition()

window.map = undefined

