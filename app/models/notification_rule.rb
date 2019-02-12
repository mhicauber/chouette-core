class NotificationRule < ApplicationModel
  extend Enumerize
  enumerize :notification_type, in: %w(hole_sentinel), default: :hole_sentinel

  # Associations
  belongs_to :workbench
  belongs_to :line, class_name: 'Chouette::Line'

  # Scopes
  scope :in_periode, -> (daterange) { where('lower(notification_rules.period) < ? AND upper(notification_rules.period) >= ?', daterange.end, daterange.begin) }

  # Validations
  validates_presence_of :workbench
  validates_presence_of :line
  validates_presence_of :notification_type
  validates_presence_of :period
end