# -*- coding: utf-8 -*-
module ExportsHelper
  def export_option_input form, export, attr, option_def, type, referentials, parent_form: nil
    parent_form ||= form
    if !!option_def[:depends_on_referential]
      out = ""
      referentials.each do |referential|
        out += content_tag :div, class: "slave", data: {master: "[name='#{parent_form.object_name}[referential_id]']", value: referential.id} do
          _opts = { depends_on_referential: false, collection: option_def[:collection].call(referential) }.reverse_update(option_def)
          export_option_input form, export, attr, _opts, type, referentials
        end
      end
      out.html_safe
    else
      opts = { required: option_def[:required], input_html: {value: export.try(attr) || option_def[:default_value]}, as: option_def[:type], selected: export.try(attr) || option_def[:default_value]}
      if option_def[:type].to_s == "boolean"
        opts[:as] = :switchable_checkbox
        opts[:input_html][:checked] = export.try(attr) || option_def[:default_value]
      end
      if option_def.has_key?(:collection)
        if option_def[:collection].is_a?(Array) && !option_def[:collection].first.is_a?(Array)
          opts[:collection] = option_def[:collection].map{|k| [translate_option_value(type, attr, k), k]}
        else
          opts[:collection] = option_def[:collection]
        end
        opts[:collection] = export.instance_exec(&option_def[:collection]) if option_def[:collection].is_a?(Proc)
      end
      opts[:label] =  translate_option_key(type, attr)
      opts[:input_html]['data-select2ed'] = true if opts[:collection]
      out = form.input attr, opts
      if option_def[:depends]
        out = content_tag :div, class: "slave", data: { master: "[name='#{parent_form.object_name}[#{option_def[:depends][:option]}]']", value: option_def[:depends][:value] } do
          out
        end.html_safe
      end
      out
    end
  end

  def import_option_input form, export, attr, option_def, type
    export_option_input form, export, attr, option_def, type, nil
  end

  def export_message_content message
    if message.message_key == "full_text"
      message.message_attributes["text"]
    else
      t([message.class.name.underscore.gsub('/', '_').pluralize, message.message_key].join('.'), message.message_attributes&.symbolize_keys || {})
    end.html_safe
  end

  def workgroup_exports workgroup
    Export::Base.user_visible_descendants.select{|e| workgroup.has_export? e.name}
  end

  def translate_option_key(parent_class, key)
    root = parent_class
    root = Destination if root < Destination
    root.tmf("#{parent_class.name.demodulize.underscore}.#{key}")
  end

  def translate_option_value(parent_class, attr, key)
    root = parent_class
    root = Destination if root < Destination
    root.tmf("#{parent_class.name.demodulize.underscore}.#{attr}_collection.#{key}")
  end

  def pretty_print_options(parent_class, options)
    options.map do |k, v|
      collection = parent_class.options[k.to_sym].has_key?(:collection)
      val = collection ? translate_option_value(parent_class, k, v) : v
      "#{translate_option_key(parent_class, k)}: #{val}"
    end.join('<br/>').html_safe
  end
end
