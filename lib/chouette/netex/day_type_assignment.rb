class Chouette::Netex::DayTypeAssignment < Chouette::Netex::Resource

  def build_xml
    offset = 0
    resource.periods.each do |period|
      offset += 1
      @builder.DayTypeAssignment(version: :any, id: id_with_entity('DayTypeAssignment', resource, suffix: offset), order: offset) do
        ref 'OperatingPeriodRef', id_with_entity('OperatingPeriod', resource, suffix: offset)
        ref 'DayTypeRef', resource.objectid
      end
    end

    resource.dates.each_with_index do |date, i|
      @builder.DayTypeAssignment(version: :any, id: id_with_entity('DayTypeAssignment', resource, suffix: i+1+offset), order: i+1+offset) do
        @builder.Date format_date(date.date)
        ref 'DayTypeRef', resource.objectid
        @builder.isAvailable('false') unless date.in_out
      end
    end
  end
end
