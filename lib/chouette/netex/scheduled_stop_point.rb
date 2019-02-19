class Chouette::Netex::ScheduledStopPoint < Chouette::Netex::Resource
  def resource_metas
    {
      version: :any,
      id: id_with_entity('ScheduledStopPoint', resource)
    }
  end

  def build_xml
    @builder.ScheduledStopPoint(resource_metas)
  end
end
