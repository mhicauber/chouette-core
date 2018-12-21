class PublicationWorker
  include Sidekiq::Worker
  extend Concerns::FailingSupport
  include Concerns::LongRunningWorker

  def perform(id)
    publication = Publication.find id
    begin
      publication.run
    rescue Exception => e
      Rails.logger.error "Publication : #{e}"
    end
  end
end
