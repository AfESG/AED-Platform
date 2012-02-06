window.ft_initialize = (canvas_id, zoom, center, and_then) ->
  tableid = 1855116
  map = new google.maps.Map(document.getElementById(canvas_id),
    center: center
    zoom: zoom
    mapTypeId: google.maps.MapTypeId.ROADMAP
  )
  layer = new google.maps.FusionTablesLayer(
    query:
      select: "location"
      from: tableid
    map: map
    options:
      suppressInfoWindows: true
  )
  infoWindow = new google.maps.InfoWindow()
  google.maps.event.addListener layer, "click", (e) ->
    infoWindow.setContent "Loading survey #" + e.row["INPCODE"].value
    infoWindow.setPosition e.latLng
    infoWindow.open map
    jQuery.get "popup/2007/" + e.row["INPCODE"].value, (data) ->
      infoWindow.setContent data
  and_then()

window.map = undefined

