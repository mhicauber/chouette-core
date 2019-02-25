class Workgroup < ApplicationModel
  NIGHTLY_AGGREGATE_CRON_TIME = 5.minutes

  belongs_to :line_referential
  belongs_to :stop_area_referential
  belongs_to :owner, class_name: "Organisation"
  belongs_to :output, class_name: 'ReferentialSuite'

  has_many :workbenches, dependent: :destroy
  has_many :imports, through: :workbenches
  has_many :calendars, dependent: :destroy
  has_many :organisations, through: :workbenches
  has_many :referentials, through: :workbenches
  has_many :aggregates
  has_many :publication_setups
  has_many :publication_apis
  has_many :compliance_check_sets, through: :workbenches

  validates_uniqueness_of :name

  validates_presence_of :line_referential
  validates_presence_of :stop_area_referential
  validates_uniqueness_of :stop_area_referential_id
  validates_uniqueness_of :line_referential_id

  validates :output, presence: true
  before_validation :initialize_output

  has_many :custom_fields

  accepts_nested_attributes_for :workbenches

  @@workbench_scopes_class = WorkbenchScopes::All
  mattr_accessor :workbench_scopes_class

  def custom_fields_definitions
    Hash[*custom_fields.map{|cf| [cf.code, cf]}.flatten]
  end

  def has_export? export_name
    export_types.include? export_name
  end

  def self.all_compliance_control_sets
    %i(after_import
      after_import_by_workgroup
      before_merge
      before_merge_by_workgroup
      after_merge
      after_merge_by_workgroup
      automatic_by_workgroup
    )
  end

  def self.workgroup_compliance_control_sets
    %i[
      after_aggregate
    ]
  end

  def self.all_compliance_control_sets_labels
    compliance_control_sets_labels all_compliance_control_sets
  end

  def self.compliance_control_sets_for_workgroup
    compliance_control_sets_labels workgroup_compliance_control_sets
  end

  def self.compliance_control_sets_by_workgroup
    compliance_control_sets_labels all_compliance_control_sets.grep(/by_workgroup$/)
  end

  def self.compliance_control_sets_by_workbench
    compliance_control_sets_labels all_compliance_control_sets.grep_v(/by_workgroup$/)
  end

  def self.import_compliance_control_sets
    compliance_control_sets_labels all_compliance_control_sets.grep(/^after_import/)
  end

  def self.before_merge_compliance_control_sets
    compliance_control_sets_labels all_compliance_control_sets.grep(/^before_merge/)
  end

  def self.after_merge_compliance_control_sets
    compliance_control_sets_labels all_compliance_control_sets.grep(/^after_merge/)
  end

  def aggregated!
    update aggregated_at: Time.now
  end

  def nightly_aggregate!
    return unless nightly_aggregate_timeframe?

    target_referentials = aggregatable_referentials.select do |r|
      aggregated_at.blank? || (r.created_at > aggregated_at)
    end

    if target_referentials.empty?
      Rails.logger.info "No aggregatable referential found for nighlty aggregate on Workgroup #{name} (Id: #{id})"
      return
    end

    aggregates.create!(referentials: target_referentials, creator: 'CRON')
    update(nightly_aggregated_at: Time.current)
  end

  def nightly_aggregate_timeframe?
    return false unless nightly_aggregate_enabled?

    time = nightly_aggregate_time.seconds_since_midnight
    current = Time.current.seconds_since_midnight

    cron_delay = NIGHTLY_AGGREGATE_CRON_TIME * 2
    within_timeframe = (current - time).abs <= cron_delay

    # "5.minutes * 2" returns a FixNum (in our Rails version)
    within_timeframe && (nightly_aggregated_at.blank? || nightly_aggregated_at < NIGHTLY_AGGREGATE_CRON_TIME.seconds.ago)
  end

  def import_compliance_control_sets
    self.class.import_compliance_control_sets
  end

  def workbench_scopes workbench
    self.class.workbench_scopes_class.new(workbench)
  end

  def all_compliance_control_sets_labels
    self.class.all_compliance_control_sets_labels
  end

  def compliance_control_sets_by_workgroup
    self.class.compliance_control_sets_by_workgroup
  end

  def compliance_control_sets_by_workbench
    self.class.compliance_control_sets_by_workbench
  end

  def before_merge_compliance_control_sets
    self.class.before_merge_compliance_control_sets
  end

  def after_merge_compliance_control_sets
    self.class.after_merge_compliance_control_sets
  end

  def aggregatable_referentials
    workbenches.map { |w| w.referential_to_aggregate }.compact
  end

  def compliance_control_set key
    id = (compliance_control_set_ids || {})[key.to_s]
    ComplianceControlSet.where(id: id).last if id.present?
  end

  def owner_workbench
    workbenches.find_by organisation_id: owner_id
  end

  private
  def self.compliance_control_sets_label(key)
    "workgroups.compliance_control_sets.#{key}".t
  end

  def self.compliance_control_sets_labels(keys)
    keys.inject({}) do |h, k|
      h[k] = compliance_control_sets_label(k)
      h
    end
  end

  def initialize_output
    self.output ||= ReferentialSuite.create
  end

  def self.default_export_types
    %w[Export::Gtfs Export::NetexFull]
  end

  def self.create_with_organisation organisation, params={}
    name = params[:name] || "#{Workgroup.ts} #{organisation.name}"

    Workgroup.transaction do
      workgroup = Workgroup.create!(name: name) do |workgroup|
        workgroup.owner = organisation
        workgroup.export_types = Workgroup.default_export_types

        workgroup.line_referential ||= LineReferential.create!(name: LineReferential.ts) do |referential|
          referential.add_member organisation, owner: true
          referential.objectid_format = :netex
          referential.sync_interval = 1 # XXX is this really useful ?
        end

        workgroup.stop_area_referential ||= StopAreaReferential.create!(name: StopAreaReferential.ts) do |referential|
          referential.add_member organisation, owner: true
          referential.objectid_format = :netex
        end
      end

      organisation.workbenches.create!(name: Workbench.ts) do |w|
        w.line_referential      = workgroup.line_referential
        w.stop_area_referential = workgroup.stop_area_referential
        w.workgroup             = workgroup
        w.objectid_format       = 'netex'
        w.prefix = organisation.code
      end

      workgroup
    end
  end

end
