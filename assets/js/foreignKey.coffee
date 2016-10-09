keysToTable =
  coid : "compnay"
  pid : "person"
  prodid : "production"
  charid : "persona"

jQuery(".enable-fks").each ->
  $el = jQuery(this)
  header = $el.find "thead"
  body = $el.find "tbody"
  toTransform = []
  headerCells = header.find "th"
  mappings = _.chain(headerCells)
    .map (value, index) -> [index, keysToTable[jQuery(value).text()]]
    .filter ([index, table]) -> table?
    .value()
  lines = body.find "tr"
  lines.each ->
    l = jQuery(this)
    cols = l.find "th, td"
    _.each mappings, ([index, table]) ->
      currentCol = cols.eq index
      content = currentCol.text()
      link = jQuery("<a>#{content}</a>")
      link.attr "href", "/details/#{table}/#{content}"
      currentCol.empty()
      link.appendTo currentCol
