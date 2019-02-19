class Chouette::Netex::OperatingPeriod < Chouette::Netex::Resource

  def build_xml
    resource.periods.each_with_index do |period, i|
      @builder.OperatingPeriod(version: :any, id: id_with_entity('OperatingPeriod', resource, suffix: i+1)) do
        @builder.FromDate format_time(period.period_start)
        @builder.ToDate format_time(period.period_end)
      end
    end
  end
end
