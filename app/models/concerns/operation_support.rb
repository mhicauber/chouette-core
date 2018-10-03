module OperationSupport
  extend ActiveSupport::Concern

  included do |into|
    into.extend Enumerize

    enumerize :status, in: %w[new pending successful failed running canceled], default: :new
    scope :successful, ->{ where status: :successful }

    has_array_of :referentials, class_name: 'Referential'
    belongs_to :new, class_name: 'Referential'

    validate :has_at_least_one_referential, :on => :create

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
end
