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

    lines = referential.metadatas_lines
    copy = ReferentialCopy.new source: current_offer, target: referential, skip_metadatas: true, lines: lines
    copy.copy!

    CleanUp.new(referential: referential, methods: %i[destroy_time_tables_outside_referential]).clean

    referential.active!
  end
end
