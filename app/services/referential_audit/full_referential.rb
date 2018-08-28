class ReferentialAudit
  class FullReferential
    include PrettyOutput

    attr_reader :referential
    attr_accessor :interfaces_group
    attr_accessor :status

    def self.register klass
      @items ||= []
      @items << klass
    end

    def self.items
      @items ||= []
    end

    def initialize referential
      @referential = referential
      @verbose = true
      @status = :new
      @number_of_lines = self.class.items.size
      @left_part = self.class.items.map(&:pretty_name).map(&:size).max + 10
      init_output
    end

    def perform opts={}
      plain_output = !!opts.delete(:plain_output)
      @output = opts.delete(:output) || :console
      @status = :success
      if @output == :slack
        ref_name = CGI::escapeHTML(referential.name)
        @banner = "<#{Rails.application.config.rails_host}/referentials/#{referential.id}|*Referential \"#{ref_name}\" (#{referential.id})*>"
      else
        @banner = "Referential \"#{referential.name}\" (#{referential.id})"
      end

      referential.switch do
        self.class.items.each do |item|
          instance = item.new(referential)
          instance.perform(self)
          if @status == :success || @status == :warning && instance.status == :error
            @status = instance.status
          end
          res = send("#{instance.status}_status")
          @statuses += res
          log res + "\t" + instance.pretty_name, silent: plain_output
          unless plain_output
            print_state
          end
          @current_line += 1
        end
      end
      @banner += ": " + send("#{@status}_status")
      full_state
    end

    def encode_string s
      s
    end

    def add_error error, criticity=:error
      @_errors ||= []
      @_errors << {kind: criticity, message: error}
    end

    def success_status
      if @output == :slack
        ":white_check_mark:"
      else
        colorize("✓", :green)
      end
    end

    def warning_status
      if @output == :slack
        ":small_orange_diamond:"
      else
        colorize("-", :orange)
      end
    end

    def error_status
      if @output == :slack
        ":red_circle:"
      else
        colorize("x", :red)
      end
    end
  end
end

require_dependency 'referential_audit/base'
