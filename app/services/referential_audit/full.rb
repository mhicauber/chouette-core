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
        out << audit.perform(plain_output: true)
      end

      out
    end
  end
end
