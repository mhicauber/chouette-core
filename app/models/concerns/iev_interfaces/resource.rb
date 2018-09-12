module IevInterfaces::Resource
  extend ActiveSupport::Concern

  included do
    extend Enumerize
    attr_accessor :rows_count

    enumerize :status, in: %i(OK ERROR WARNING IGNORED), scope: true
    validates_presence_of :name, :resource_type
    before_save :update_metrics
    after_initialize do
      self.rows_count ||= 0
    end
  end

  def each collection
    collection.each do |item|
      inc_rows_count
      yield item, self
    end
    save!
    self
  end

  def inc_rows_count
    @rows_count += 1
  end

  def update_status_from_importer importer_status
    self.update status: status_from_importer(importer_status)
  end

  def update_status_from_messages
    self.update status: status_from_messages
  end

  def status_from_messages
    status = if messages.where(criticity: :error).exists?
      :ERROR
    elsif messages.where(criticity: :warning).exists?
      :WARNING
    else
      :OK
    end
  end

  def update_metrics
    warning = messages.warning.count
    error = messages.error.count
    self.metrics = {
      ok_count: [self.rows_count - warning - error].max,
      warning_count: warning,
      error_count: error
    }
  end

  def status_from_importer importer_status
    return nil unless importer_status.present?
    {
      new: nil,
      pending: nil,
      successful: :OK,
      warning: :WARNING,
      failed: :ERROR,
      running: nil,
      aborted: :ERROR,
      canceled: :ERROR
    }[importer_status.to_sym]
  end
end
