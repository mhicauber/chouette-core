class ReferentialAudit
  class Full
    def perform opts={}
      referentials = Referential.not_in_referential_suite.uniq
      referentials += Workbench.all.map { |w| w.output.current }.compact
      out = []
      referentials = referentials[0..5] if opts[:debug]
      referentials.sort_by(&:created_at).uniq.reverse.each do |referential|
        audit = ReferentialAudit::FullReferential.new referential
        out << audit.perform(plain_output: true)
      end

      out
    end
  end
end
