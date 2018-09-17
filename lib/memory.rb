module Memory
  def self.log(step, &block)
    Rails.logger.debug "Memory before #{step}: #{current_usage}"
    result = yield
    Rails.logger.debug "Memory after #{step}: #{current_usage}"
    result
  end

  def self.current_usage
    NewRelic::Agent::Samplers::MemorySampler.new.sampler.get_sample
  end
end
