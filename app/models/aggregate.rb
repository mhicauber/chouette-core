class Aggregate < ActiveRecord::Base
  include OperationSupport

  belongs_to :workgroup
  has_many :compliance_check_sets, -> { where(parent_type: "Aggregate") }, foreign_key: :parent_id, dependent: :destroy

  validates :workgroup, presence: true

  after_commit :aggregate, :on => :create

  delegate :output, to: :workgroup

  def parent
    workgroup
  end

  def aggregate
    update_column :started_at, Time.now
    update_column :status, :running

    AggregateWorker.perform_async(id)
  end

  def aggregate!
    prepare_new

    if after_aggregate_compliance_control_set.present?
      create_after_aggregate_compliance_check_set
    else
      save_current
    end
  rescue => e
    Rails.logger.error "Aggregate failed: #{e} #{e.backtrace.join("\n")}"
    failed!
    raise e #if Rails.env.test?
  end

  def failed!
    update status: :failed, ended_at: Time.now
    new&.failed!
    referentials.each &:active!
  end

  def save_current
    output.update current: new, new: nil
    output.current.update referential_suite: output, ready: true

    clean_previous_operations
    update status: :successful, ended_at: Time.now
  end

  def child_change
    Rails.logger.debug "Aggregate #{self.inspect} child_change"
    # Wait next child change if one of the check isn't finished
    return if compliance_check_sets.unfinished.exists?

    if compliance_check_sets.all? { |c| c.status.in? %w{successful warning} }
      if new
        # We are done
        save_current
      else
        # We just passed 'before' validations
        if self.aggregate_scheduled?
          Rails.logger.warn "Trying to schedule a Merge while it is already enqueued (Merge ID: #{id})"
        else
          AggregateWorker.perform_async(id)
        end
      end
    else
      referentials.each &:active!
      update status: :failed, ended_at: Time.now
    end
  end

  def compliance_check_set(key, referential = nil)
    referential ||= new
    control = workgroup.compliance_control_set(key)
    compliance_check_sets.where(compliance_control_set_id: control.id).find_by(referential_id: referential.id, context: key) if control
  end

  private

  def aggregate_scheduled?
    queue = Sidekiq::Queue[MergeWorker.sidekiq_options["queue"]]
    queue.any? { |item| item["class"] == "AggregateWorker" && item.args == [self.id] }
  end

  def prepare_new
    Rails.logger.debug "Create a new output"
    # 'empty' one
    attributes = {
      organisation: workgroup.owner,
      prefix: "aggregate_#{id}",
      line_referential: workgroup.line_referential,
      stop_area_referential: workgroup.stop_area_referential,
      objectid_format: referentials.first.objectid_format
    }
    new = workgroup.output.referentials.new attributes
    new.referential_suite = output
    new.slug = "output_#{workgroup.id}_#{created_at.to_i}"
    new.name = I18n.t("aggregates.referential_name", date: I18n.l(created_at))

    unless new.valid?
      Rails.logger.error "New referential isn't valid : #{new.errors.inspect}"
    end

    begin
      new.save!
    rescue
      Rails.logger.debug "Errors on new referential: #{new.errors.messages}"
      raise
    end

    new.pending!

    output.update new: new
    update new: new
  end

  def after_aggregate_compliance_control_set
    @after_aggregate_compliance_control_set ||= workgroup.compliance_control_set(:after_aggregate)
  end

  def create_after_aggregate_compliance_check_set
    create_compliance_check_set :after_aggregate, after_aggregate_compliance_control_set, new
  end

  def create_compliance_check_set(context, control_set, referential)
    ComplianceControlSetCopier.new.copy control_set.id, referential.id, self.class.name, id, context
  end
end
