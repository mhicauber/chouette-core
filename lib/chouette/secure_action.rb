module Chouette
  class SecureAction
    attr_accessor :verbose

    def initialize(description, verbose: false, &block)
      @description = description
      @content = block
      @caller = caller[1]
      @verbose = verbose
    end

    def on_success(&block)
      @on_success = block
    end

    def on_failure(raise_error: false, &block)
      @raise_error_on_failure = raise_error
      @on_failure = block
    end

    def ensure(&block)
      @ensure = block
    end

    def duration
      raise ActionNotCalled unless @end_time
      @end_time - @start_time
    end

    def memory_usage
      raise ActionNotCalled unless @memory_after
      @memory_after - @memory_before
    end

    def call
      begin
        @start_time = Time.now
        @memory_before = Chouette::Benchmark.current_usage
        @res = @content.call
        @on_success&.call
        @status = :success
        @res
      rescue => e
        Chouette::ErrorsManager.log "#{@description} failed", error: e
        @on_failure&.call
        @status = :failed
        raise if @raise_error_on_failure
      ensure
        @end_time = Time.now
        @memory_after = Chouette::Benchmark.current_usage
        @ensure&.call
        log_info if verbose
      end
    end

    def log_info
      info = ["SecureAction: '#{@description}'"]
      info << "Caller:\t\t#{@caller}"
      info << "Status:\t\t#{@status}"
      info << "Duration:\t#{duration}s"
      info << "Memory Usage:\t#{memory_usage} (#{@memory_before} > #{@memory_after})"
      Chouette::ErrorsManager.log info.join("\n")
    end

    class ActionNotCalled < RuntimeError; end
  end
end
