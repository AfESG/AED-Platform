window.hide_history_window = hide_history_window = ->
  $('.history_window').hide()
  $('.history_window').remove()

create_history_window = ->
  $('body').append('<div class="history_window"><div class="history_window_x"><span class="glyphicon glyphicon-remove"></span></div><div class="history_window_contents"></div></div>')
  $('.history_window_x').on 'click', ->
    hide_history_window()

populate_history_window = (data) ->
  whodunnit_when = ''
  $.each data, (index,item)->
    my_whodunnit_when = "#{item.whodunnit}#{item.ago}"
    if whodunnit_when != my_whodunnit_when
      $('.history_window_contents').append("<div class='history_whodunnit'>#{item.whodunnit}</div><div class='history_ago'>#{item.ago}</div>")
      whodunnit_when = my_whodunnit_when
    $.each item.changeset, (index,change) ->
      if index == 'comments'
        $.each [0,1], (i) ->
          if change[i] == null
            change[i] = ''
          change[i] = change[i].replace(/\n/,'').replace(/^\s+|\s+$/g,'')
        if change[1] == ''
          if change[0] != ''
            $('.history_window_contents').append("<div class='history_resolved'>Resolved</div>")
        else
          $('.history_window_contents').append("<div class='history_comments'>#{change[1]}</div>")
      else
        $('.history_window_contents').append("<div class='history_changeset'>#{index}: #{change[1]}</div>")
  $('.history_window').show()

window.reveal_history = reveal_history = (object_type, object_id, and_then) ->
  hide_history_window()
  create_history_window()
  $.ajax
    type: "GET"
    url: "/history/#{object_type}/#{object_id}"
    error: (data) ->
      alert "Error retrieving version history for this item."
    success: (data) ->
      populate_history_window(data)
      and_then() if and_then
