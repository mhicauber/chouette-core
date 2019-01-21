class PublicationApiSource < ActiveRecord::Base
  include RemoteFilesHandler

  belongs_to :publication_api
  belongs_to :publication

  validates :publication_api, presence: true
  validates :publication, presence: true

  attr_accessor :export
  mount_uploader :file, ImportUploader

  before_save :cleanup_previous
  after_save :download_file

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

  protected

  def cleanup_previous
    return unless export

    self.key = generate_key
    PublicationApiSource.where(publication_api_id: publication_api_id, key: key).destroy_all
  end

  def download_file
    return unless export
    
    self.remote_file_url = build_remote_file_url(export.file)
    self.export = nil
    self.save
  end

  def generate_key
    self.class.generate_key export
  end
end
