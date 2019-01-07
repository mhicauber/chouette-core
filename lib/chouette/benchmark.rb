module Chouette
  module Benchmark
    def self.log(step, &block)
      result = nil
      memory_before = current_usage

      time = ::Benchmark.realtime do
        result = yield
      end

      memory_after = current_usage
      Rails.logger.info "#{step} operation : #{time} seconds / memory delta #{memory_after - memory_before} (#{memory_before} > #{memory_after})"

      result
    end

    def self.current_usage
      NewRelic::Agent::Samplers::MemorySampler.new.sampler.get_sample
    end
  end
end
