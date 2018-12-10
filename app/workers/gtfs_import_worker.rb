class GtfsImportWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker
  extend Concerns::FailingSupport

  def perform(import_id)
    import = Import::Gtfs.find(import_id)
    import.import
  end
end
