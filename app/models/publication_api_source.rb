class PublicationApiSource < ActiveRecord::Base
  include RemoteFilesHandler

  belongs_to :publication_api
  belongs_to :publication
  belongs_to :export, class_name: 'Export::Base'

  validates :publication_api, presence: true
  validates :publication, presence: true

  before_save :cleanup_previous

  delegate :file, to: :export

  def self.generate_key(export)
    return unless export.present?

    out = []
    out << export.class.name.demodulize.downcase

    if export.is_a?(Export::Netex)
      out << export.export_type
      if export.export_type == "line"
        line = Chouette::Line.find export.line_code
        out << line.code
      end
    end

    out.join('-')
  end

  def public_url
    base = publication_api.public_url
    setup = publication.publication_setup
    case setup.export_type.to_s
    when "Export::Gtfs"
      base += ".#{key}.zip"
    when "Export::Netex"
      if setup.export_options['export_type'] == 'full'
        base += ".#{key}.zip"
      else
        *split_key, line = key.split('-')
        base += "/lines/#{line}.#{split_key.join('-')}.zip"
      end
    end

    base
  end

  protected

  def cleanup_previous
    return unless export

    self.key ||= generate_key
    PublicationApiSource.where(publication_api_id: publication_api_id, key: key).destroy_all
  end

  def generate_key
    self.class.generate_key export
  end
end
