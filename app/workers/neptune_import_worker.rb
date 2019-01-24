class NeptuneImportWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker
  extend Concerns::FailingSupport

  def perform(import_id)
    Import::Neptune.find(import_id).import
  end
end
