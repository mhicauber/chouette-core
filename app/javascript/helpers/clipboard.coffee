class ClipboardHelper
  @copy: (content)->
    out = ""
    for _, row of content
      line = []
      for _, cell of row
        if cell.hour || cell.hour == 0
          hour = parseInt cell.hour
          hour = '0' + hour if hour < 10
          minute = parseInt cell.minute
          minute = '0' + minute if minute < 10
          cell_content = "#{hour}:#{minute}"
        line.push cell_content
      out += line.join("\t") + "\n"

    out

  @paste: (rawContent, selection)->
    error = null
    if rawContent
      out = []
      for _, row of rawContent.split("\n")
        if row.length > 0
          line = []
          for _, cell of row.split("\t")
            [hour, minute] = cell.split(':')
            hour = Math.min(23, parseInt(hour))
            minute = Math.min(59, parseInt(minute))
            line.push { hour: hour, minute: minute }
          out.push line
      out
      error = 'size_does_not_match' unless @size_match(out, selection)
    else
      error = 'missing_content'

    { content: out, error }

  @size_match: (content, selection)->
    content.length == selection.height &&
    content.length > 0 &&
    content[0].length == selection.width

export default ClipboardHelper
