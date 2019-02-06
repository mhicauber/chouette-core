module Chouette
  class SecureAction
    attr_accessor :verbose

    def initialize(description, verbose: false, shift_caller: false, &block)
      @description = description
      @content = block
      if shift_caller
        @caller = caller[2]
      else
        @caller = caller[1]
      end

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
        finished!
        @status = :failed
        Chouette::ErrorsManager.log "#{@description} failed", error: e, extra_infos: infos
        @on_failure&.call
        raise if @raise_error_on_failure
      ensure
        finished!
        @ensure&.call
        log_infos if verbose && @status == :success
      end
    end

    def finished!
      @memory_after = Chouette::Benchmark.current_usage
      @end_time = Time.now
    end

    def infos
      infos = ["SecureAction: '#{@description}'"]
      infos << "Caller:\t\t#{@caller}"
      infos << "Status:\t\t#{@status}"
      infos << "Duration:\t#{duration}s"
      infos << "Memory Usage:\t#{memory_usage} (#{@memory_before} > #{@memory_after})"
      infos
    end

    def log_infos
      Chouette::ErrorsManager.log infos.join("\n")
    end

    class ActionNotCalled < RuntimeError; end
  end
end
