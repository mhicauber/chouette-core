class GTFSExportWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker
  extend Concerns::FailingSupport

  # Workers
  # =======

  def perform(export_id)
    @entries = 0
    gtfs_export = Export::Gtfs.find(export_id)
    gtfs_export.run
  end
end
