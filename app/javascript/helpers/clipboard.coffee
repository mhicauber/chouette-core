class ClipboardHelper
  @serialize_cell_content: (time)->
    hour = parseInt time.hour
    hour = '0' + hour if hour < 10
    minute = parseInt time.minute
    minute = '0' + minute if minute < 10
    "#{hour}:#{minute}"

  @parse_cell_content: (cell)->
    [hour, minute] = cell.split(':')
    hour = Math.min(23, parseInt(hour))
    minute = Math.min(59, parseInt(minute))
    { hour: hour, minute: minute }

  @copy: (content, toggleArrivals)->
    console.log({content, toggleArrivals})
    out = ""
    for _, row of content
      line = []
      for _, cell of row
        line.push @serialize_cell_content(cell.arrival_time) if toggleArrivals
        line.push @serialize_cell_content(cell.departure_time)
      out += line.join("\t") + "\n"

    out

  @paste: (rawContent, selection, toggleArrivals)->
    error = null
    if rawContent
      out = []
      for _, row of rawContent.split("\n")
        if row.length > 0
          line = []
          for i, cell of row.split("\t")
            if toggleArrivals
              if i%2 == 1
                line[line.length - 1]['departure_time'] = @parse_cell_content(cell)
              else
                line.push {arrival_time: @parse_cell_content(cell)}
            else
              line.push {departure_time: @parse_cell_content(cell)}
          out.push line
      out
      error = 'size_does_not_match' unless @size_match(out, selection, toggleArrivals)
    else
      error = 'missing_content'

    { content: out, error }

  @size_match: (content, selection, toggleArrivals)->
    return false unless content.length > 0

    res = content.length == selection.height && content[0].length == selection.width
    if toggleArrivals
      res = res && !!content[0][content[0].length - 1].departure_time

    res

export default ClipboardHelper
