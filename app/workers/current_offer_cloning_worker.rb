class CurrentOfferCloningWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker

  def self.fill_from_current_offer(referential)
    referential.pending!
    perform_async referential.id
  end

  def perform(referential_id)
    referential = Referential.find referential_id
    current_offer = referential.workbench.output.current

    line_ids = referential.metadatas.pluck(:line_ids).flatten.uniq
    periods = referential.metadatas.pluck(:periodes).flatten
    period_start = periods.map(&:min).min
    period_end = periods.map(&:max).max

    cloning = ReferentialCloning.new source_referential: current_offer, target_referential: referential
    cloning.clone!

    referential.metadatas.destroy_all
    current_offer.metadatas.each do |metadata|
      new_metadata = metadata.dup
      new_metadata.referential = referential
      new_metadata.line_ids = new_metadata.line_ids & line_ids
      new_metadata.periodes = new_metadata.periodes.map {|p| ([p.min, period_start].max .. [p.max, period_end].min)}.select{|p| p.count > 0}

      new_metadata.save! if new_metadata.periodes.present? && new_metadata.line_ids.present?
    end
    CleanUp.new(referential: referential, begin_date: period_start, date_type: :before).clean
    CleanUp.new(referential: referential, end_date: period_end, date_type: :after).clean
    CleanUp.new(referential: referential, methods: [:destroy_empty, :destroy_unassociated_calendars]).clean

    referential.active!
  end
end
