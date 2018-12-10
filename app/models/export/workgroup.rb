class Export::Workgroup < Export::Base
  after_commit :launch_worker, :on => :create

  option :duration, required: true, type: :integer, default_value: 90

  def launch_worker
    WorkgroupExportWorker.perform_async_or_fail(id: id) do
      update_column :status, 'failed'
    end
  end
end
