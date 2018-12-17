class WorkgroupExportWorker
  include Sidekiq::Worker
  extend Concerns::FailingSupport

  attr_reader :workbench_export

  # Workers
  # =======

  def perform(export_id)
    @entries = 0
    @workbench_export ||= Export::Workgroup.find(export_id)

    workbench_export.update(status: 'running', started_at: Time.now)
    create_sub_jobs
  rescue Exception => e
    logger.error e.message
    workbench_export.update( status: 'failed' )
    raise
  end

  def create_sub_jobs
    # XXX TO DO
    workbench_export.workbench.workgroup.referentials.each do |ref|
      ref.lines.each do |line|
        netex_export = Export::Netex.new
        netex_export.name = "Export line #{line.name} of Referential #{ref.name}"
        netex_export.workbench = workbench_export.workbench
        netex_export.creator = workbench_export.creator
        netex_export.export_type = :line
        netex_export.referential = workbench_export.referential
        netex_export.duration = workbench_export.duration
        netex_export.line_code = line.objectid
        netex_export.parent = workbench_export
        netex_export.save!
      end
    end
  end

end
