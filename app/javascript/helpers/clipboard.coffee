class ClipboardHelper
  @copy: (content)->
    console.log 'copy to clipboard'
    console.log content
    out = ""
    for _, row of content
      line = []
      for _, cell of row
        if cell.hour
          cell_content = "#{cell.hour}:#{cell.minute}"
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
