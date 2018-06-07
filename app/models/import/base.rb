class Import::Base < ApplicationModel
  self.table_name = "imports"

  def self.messages_class_name
    "Import::Message"
  end

  def self.resources_class_name
    "Import::Resource"
  end

  def self.file_extension_whitelist
    %w(zip)
  end

  include IevInterfaces::Task
  validates_presence_of :file, unless: Proc.new {|import| import.errors[:file].present? }

  def self.model_name
    ActiveModel::Name.new Import::Base, Import::Base, "Import"
  end

  def child_change
    Rails.logger.info "child_change for #{inspect}"
    return if self.class.finished_statuses.include?(status)

    super
  end

  private

  def initialize_fields
    super
    self.token_download ||= SecureRandom.urlsafe_base64
  end

end
