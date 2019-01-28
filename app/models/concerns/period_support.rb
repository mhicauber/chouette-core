module PeriodSupport
  extend ActiveSupport::Concern

  included do
    after_initialize :init_date_ranges

    def init_date_ranges
      return unless self.attributes.has_key?('date_ranges')

      self.date_ranges ||= []
    end

    ### Calendar::Period
    # Required by coocon
    def build_period
      Calendar::Period.new
    end

    def periods
      @periods ||= init_periods
    end

    def init_periods
      (date_ranges || [])
        .each_with_index
        .map( &Calendar::Period.method(:from_range) )
    end
    private :init_periods

    validate :validate_periods

    def validate_periods
      periods_are_valid = periods.all?(&:valid?)

      periods.each do |period|
        if period.intersect?(periods)
          period.errors.add(:base, I18n.t('calendars.errors.overlapped_periods'))
          periods_are_valid = false
        end
      end

      unless periods_are_valid
        errors.add(:periods, :invalid)
      end
    end

    def flatten_date_array attributes, key
      date_int = %w(1 2 3).map {|e| attributes["#{key}(#{e}i)"].to_i }
      Date.new(*date_int)
    end

    def periods_attributes=(attributes = {})
      @periods = []
      attributes.each do |index, period_attribute|
        # Convert date_select to date
        ['begin', 'end'].map do |attr|
          period_attribute[attr] = flatten_date_array(period_attribute, attr)
        end
        period = Calendar::Period.new(period_attribute.merge(id: index))
        @periods << period unless period.marked_for_destruction?
      end

      date_ranges_will_change!
    end

    before_validation :fill_date_ranges

    def fill_date_ranges
      if @periods
        self.date_ranges = @periods.map(&:range).compact.sort_by(&:begin)
      end
    end

    after_save :clear_periods

    def clear_periods
      @periods = nil
    end

    private :clear_periods
  end
end
