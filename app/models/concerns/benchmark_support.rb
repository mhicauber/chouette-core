module BenchmarkSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def benchmark(object, method_name)
      time = Benchmark.realtime do
        object.send(method_name.to_sym)
      end
      Rails.logger.info "#{method_name.to_s} operation took #{time} seconds"
    end
  end
end