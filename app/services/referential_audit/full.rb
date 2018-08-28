class ReferentialAudit
  class Full
    def perform opts={}
      limit = opts.delete(:limit)
      referentials = Referential.not_in_referential_suite.uniq
      referentials += Workbench.all.map { |w| w.output.current }.compact
      referentials = referentials.uniq.sort_by(&:created_at).reverse
      out = []
      if limit
        if limit.is_a? Integer
          referentials = referentials[0..limit]
        elsif limit.is_a?(Time) || limit.is_a?(Date)
          referentials = referentials.select{|r| r.created_at > limit }
        end
      end

      referentials.each do |referential|
        audit = ReferentialAudit::FullReferential.new referential
        res = audit.perform(opts.dup.update({plain_output: true}))
        if block_given?
          yield res, audit
        end
        out << res
      end

      out
    end

    def push_to_slack
      return unless AF83::Slack.enabled?
      AF83::Slack.push "*Referentials Audit as of #{Time.now.l(format: :short)}* (<#{Rails.application.config.rails_host}>)"
      perform(output: :slack) do |res, audit|
        AF83::Slack.push res unless audit.status == :success
      end
    end
  end
end
