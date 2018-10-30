require 'net/http/post/multipart'

class Export::Base < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include OptionsSupport

  self.table_name = "exports"

  belongs_to :referential

  validates :type, :referential_id, presence: true

  LOG_LEVEL_ERROR = :ERROR
  LOG_LEVEL_WARN  = :WARN
  LOG_LEVEL_INFO  = :INFO
  LOG_LEVEL_DEBUG = :DEBUG
  LOG_LEVELS = [LOG_LEVEL_ERROR, LOG_LEVEL_WARN, LOG_LEVEL_INFO, LOG_LEVEL_DEBUG].freeze

  @@log_level = LOG_LEVEL_WARN

  def self.log_level
    @@log_level
  end

  def self.log_level=(level)
    return unless LOG_LEVELS.include?(level)

    @@log_level = level
  end

  def log_level
    self.class.log_level
  end

  def self.log_level_greater_than?(level)
    return false unless LOG_LEVELS.include?(level)

    LOG_LEVELS.index(@@log_level) >= LOG_LEVELS.index(level)
  end

  def log_level_greater_than?(level)
    self.class.log_level_greater_than?(level)
  end

  def self.messages_class_name
    "Export::Message"
  end

  def self.resources_class_name
    "Export::Resource"
  end

  def self.human_name
    I18n.t("export.#{self.name.demodulize.underscore}")
  end

  def self.file_extension_whitelist
    %w(zip csv json)
  end

  def upload_file file
    url = URI.parse upload_workbench_export_url(self.workbench_id, self.id, host: Rails.application.config.rails_host)
    res = nil
    filename = File.basename(file.path)
    content_type = MIME::Types.type_for(filename).first&.content_type
    File.open(file.path) do |file_content|
      req = Net::HTTP::Post::Multipart.new url.path,
        file: UploadIO.new(file_content, content_type, filename),
        token: self.token_upload
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    end
    res
  end

  if Rails.env.development?
    def self.force_load_descendants
      path = Rails.root.join 'app/models/export'
      Dir.chdir path do
        Dir['**/*.rb'].each do |src|
          next if src =~ /^base/
          klass_name = "Export::#{src[0..-4].camelize}"
          Rails.logger.info "Loading #{klass_name}"
          begin
            klass_name.constantize
          rescue => e
            Rails.logger.info "Failed: #{e.message}".red
            nil
          end
        end
      end
    end
  end

  def self.user_visible?
    false
  end

  def self.inherited child
    super child
    child.instance_eval do
      def self.user_visible?
        true
      end
    end
  end

  include IevInterfaces::Task

  def self.model_name
    ActiveModel::Name.new Export::Base, Export::Base, "Export"
  end

  def self.user_visible_descendants
    descendants.select &:user_visible?
  end

  def self.user_visible?
    true
  end

  private

  def initialize_fields
    super
    self.token_upload = SecureRandom.urlsafe_base64
  end

end
