module OperationSupport
  extend ActiveSupport::Concern

  included do |into|
    into.extend Enumerize

    enumerize :status, in: %w[new pending successful failed running canceled], default: :new
    scope :successful, ->{ where status: :successful }

    has_array_of :referentials, class_name: 'Referential'
    belongs_to :new, class_name: 'Referential'

    validate :has_at_least_one_referential, :on => :create
    validate :check_other_operations, :on => :create

    into.extend ClassMethods

    @keep_operations = 20
  end

  module ClassMethods
    def keep_operations=(value)
      @keep_operations = [value, 1].max # we cannot keep less than 1 operation
    end

    def keep_operations
      @keep_operations
    end
  end

  def name
    created_at.l(format: :short_with_time)
  end

  def full_names
    referentials.map(&:name).to_sentence
  end

  def clean_previous_operations
    while clean_scope.successful.count > [self.class.keep_operations, 0].max do
      clean_scope.order("created_at asc").first.tap { |m| m.new&.destroy ; m.destroy }
    end
  end

  def has_at_least_one_referential
    unless referentials.length > 0
      errors.add(:base, :no_referential)
    end
  end

  def clean_scope
    parent&.send(self.class.name.tableize)
  end

  def check_other_operations
    if clean_scope && clean_scope.where(status: [:new, :pending, :running]).exists?
      Rails.logger.warn "Pending #{self.class.name}(s) on #{parent.class.name} #{parent.name}/#{parent.id}"
      errors.add(:base, :multiple_process)
    end
  end

end
