if jQuery("#editor_button").length isnt 0
  editor = ace.edit "editor"
  editor.getSession().setMode "ace/mode/sql"
  jQuery("#editor_button").click () ->
    url = jQuery(this).data "url"
    if url? and url isnt ""
      form = jQuery("<form></form>")
      form.attr "action", url
      form.attr "method", "POST"
      input = jQuery("<input></input>")
      input.attr "type", "hidden"
      input.attr "name", "request"
      input.attr "value", editor.getSession().getValue()
      form.append input
      form.submit()






