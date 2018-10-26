module MailerHelper
  def mailer_link_to(text, url, opts = {}, &block)
    link_to text, url, opts.update(style: mailer_style(:link)), &block
  end

  def mailer_button(text, url, opts = {})
    link_to text, url, opts.update(style: mailer_style(:button))
  end

  def mailer_stylesheets_path
    File.join Rails.root, 'app', 'assets', 'stylesheets', 'mailers'
  end

  def mailer_style(component)
    stylesheet = File.read File.join mailer_stylesheets_path, 'components', "#{component}.sass"

    custom_stylesheet_path = File.join mailer_stylesheets_path, 'components', 'custom', "#{component}.sass"
    if File.exist? custom_stylesheet_path
      stylesheet += File.read custom_stylesheet_path
    end
    stylesheet = "dummy\n#{stylesheet.lines.map { |t| "  #{t}" }.join("\n")}"
    raw = Sass::Engine.new(stylesheet, style: :compact).render
    raw.present? ? raw.match(/dummy {(.*)}/)[1] : ''
  end

  def mailer_base_css
    stylesheet = File.read File.join mailer_stylesheets_path, 'base.sass'
    Dir["#{mailer_stylesheets_path}/custom/*.sass"].each do |f|
      stylesheet += "\n@import 'custom/#{File.basename f}'"
    end
    sass_engine = Sass::Engine.new stylesheet,
                                   load_paths: [mailer_stylesheets_path]
    "<style>#{sass_engine.render}</style>".html_safe
  end

  def render_custom(name)
    path = File.join(
      Rails.root,
      'app',
      'views',
      'layouts',
      'mailer',
      'custom',
      "_#{name}.html.*"
    )
    if !Dir.glob(path).empty?
      render partial: "layouts/mailer/custom/#{name}"
    else
      render partial: "layouts/mailer/#{name}"
    end
  end

  def mail_footer
    render_custom :footer
  end

  def mail_header
    render_custom :header
  end
end
