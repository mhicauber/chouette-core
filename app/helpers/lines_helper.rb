module LinesHelper

  def line_sticker( line)
    return line.name if line.number.blank?
    line.number
  end

  def colors?(line)
    line.text_color.present? || line.color.present?
  end

  def text_color(line)
    line.text_color.blank? ? "black" : "##{line.text_color}"
  end

  def background_color(line)
    line.color.blank? ? "white" : "#"+line.color
  end

  def number_style(line)
    if colors?(line)
      number_style = "color: #{text_color(line)}; background-color: #{background_color(line)};"
    else
      number_style = ""
    end

  end

  def status_symbol(status)
    if status == 'activated'
      "<span class='fa fa-check-circle text-success'></span>"
    else
      "<span class='fa fa-exclamation-circle text-danger'></span>"
    end
  end
end
