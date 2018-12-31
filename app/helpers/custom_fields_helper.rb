module CustomFieldsHelper
  def custom_fields_for_section(form, section)
    resource = form.object
    return if resource.custom_fields.for_section(section).blank?
    fields = resource.custom_fields.for_section(section).map do |_code, field|
      field.input(form).to_s
    end
    fields.join.html_safe
  end

  def custom_fields_by_resource_type(parent)
    Hash.new {|h,k| h[k] = []}.tap do |out|
      parent.custom_fields.order(:name).each do |cf|
        next unless cf.resource_class
        out[cf.resource_class.ts] << [cf.name, cf.code]
      end
    end
  end
end
