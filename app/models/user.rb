class User < ApplicationModel
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :database_authenticatable

  @@authentication_type = "#{Rails.application.config.chouette_authentication_settings[:type]}_authenticatable".to_sym
  cattr_reader :authentication_type
  cattr_accessor :cas_updater

  def self.more_devise_modules
    if Subscription.enabled?
      [:confirmable]
    else
      []
    end
  end

  devise :invitable, :registerable, :validatable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :async, authentication_type, *more_devise_modules

  if Subscription.enabled?
    self.allow_unconfirmed_access_for = 1.day
  end

  # FIXME https://github.com/nbudin/devise_cas_authenticatable/issues/53
  # Work around :validatable, when database_authenticatable is disabled.
  attr_accessor :password unless authentication_type == :database_authenticatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :current_password, :password_confirmation, :remember_me, :name, :organisation_attributes
  belongs_to :organisation
  has_many :workbenches, through: :organisation
  has_many :workgroups, through: :workbenches
  accepts_nested_attributes_for :organisation

  validates :organisation, :presence => true
  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true

  before_validation(:on => :create) do
    self.password ||= Devise.friendly_token.first(6)
    self.password_confirmation ||= self.password
  end

  before_validation do
    # we sort permissions to make it easier to match them against profiles
    self.permissions&.sort!
  end

  after_destroy :check_destroy_organisation

  scope :with_organisation, -> { where.not(organisation_id: nil) }

  scope :from_workgroup, ->(workgroup_id) { joins(:workbenches).where(workbenches: {workgroup_id: workgroup_id}) }

  scope :with_profiles, ->(*profile_names) do
    profile_names = profile_names.map(&:to_s).uniq
    actual_profiles = profile_names.dup - [Permission::Profile::DEFAULT_PROFILE.to_s]
    q = (['permissions::text[] = ARRAY[?]'] * actual_profiles.size)
    permissions = actual_profiles.map {|p| Permission::Profile.permissions_for(p) }

    if profile_names.include?(Permission::Profile::DEFAULT_PROFILE.to_s)
      remaining_profiles = Permission::Profile.all - actual_profiles
      sub_q = (['permissions::text[] <> ARRAY[?]'] * remaining_profiles.size).join(' AND ')
      q << "(#{sub_q})"
      permissions += remaining_profiles.map {|p| Permission::Profile.permissions_for(p) }
    end

    where(q.join(' OR '), *permissions)
  end

  scope :with_states, ->(*states) do
    subqueries = states.select(&:present?).map{|state| "(#{subquery_for_state(state)})" }
    where(subqueries.join(' OR '))
  end

  def self.ransackable_scopes(auth_object = nil)
    super + %w[with_profiles with_states]
  end

  # Callback invoked by DeviseCasAuthenticable::Model#authernticate_with_cas_ticket
  def cas_extra_attributes=(extra_attributes)
     self.class.cas_updater&.update self, extra_attributes
  end

  def has_permission?(permission)
    permissions && permissions.include?(permission)
  end

  def can_monitor_sidekiq?
    has_permission?("sidekiq.monitor")
  end

  def email_recipient
    "#{name} <#{email}>"
  end

  def profile=(profile_name)
    self.permissions = Permission::Profile.permissions_for(profile_name)
  end

  def profile
    Permission::Profile.profile_for(permissions).to_sym
  end

  def blocked?
    locked_at.present?
  end

  def invited?
    invitation_sent_at.present?
  end

  def confirmed?
    confirmed_at.present?
  end

  def state
    %i[blocked confirmed invited].each do |s|
      return s if send("#{s}?")
    end

    :pending
  end

  def self.all_states
    %i[blocked confirmed invited pending]
  end

  def self.all_states_i18n
    all_states.map {|p| [p.to_s, "users.states.#{p}".t]}
  end

  def self.subquery_for_state(state)
    case state.to_s

    when 'blocked'
      'locked_at IS NOT NULL'
    when 'confirmed'
      'confirmed_at IS NOT NULL AND locked_at IS NULL'
    when 'invited'
      'invitation_sent_at IS NOT NULL AND confirmed_at IS NULL AND locked_at IS NULL'
    when 'pending'
      'invitation_sent_at IS NULL AND confirmed_at IS NULL AND locked_at IS NULL'
    end
  end

  private

  # remove organisation and referentials if last user of it
  def check_destroy_organisation
    if organisation.users.empty?
      organisation.destroy
    end
  end

end
