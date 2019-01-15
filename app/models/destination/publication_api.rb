class Destination::PublicationApi < ::Destination
  def do_transmit(publication, report)
    publication.exports.each do |export|
      next unless export.successful?
      
      PublicationApiSource.create publication_api: publication_api, publication: publication, export: export
    end
  end
end
