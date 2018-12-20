module ImportResourcesSupport
  extend ActiveSupport::Concern

  def main_resource
    @resource ||= parent.resources.find_or_create_by(name: referential_name, resource_type: 'referential', reference: self.name) if parent
  end

  def update_main_resource_status
    main_resource&.update_status_from_importer status
    true
  end

  def next_step
    main_resource.next_step
  end

  def create_message args, opts={}
    resource = opts[:resource] || main_resource || self
    message = resource.messages.build args
    return message unless opts[:commit]

    Chouette::ErrorsManager.watch(
      raise_error: true,
      on_failure: -> { Chouette::ErrorsManager.log "Last message: #{resource.messages.last.errors.inspect}" }
    ) { resource.save! }
    resource.update_status_from_messages
  end

  def create_resource name
    resources.find_or_initialize_by(name: name, resource_type: 'file', reference: name)
  end
end
