class Chouette::Netex::PassengerStopAssignment < Chouette::Netex::Resource
  def resource_metas
    {
      version: :any,
      id: id_with_entity('PassengerStopAssignment', resource),
      order: 0
    }
  end

  def parent_ref
    resource.stop_area_light.area_type == 'zdep' ? 'QuayRef' : 'StopPlaceRef'
  end

  def build_xml
    @builder.PassengerStopAssignment(resource_metas) do
      ref 'ScheduledStopPointRef', id_with_entity('ScheduledStopPoint', resource)
      ref parent_ref, resource.stop_area_light.objectid
    end
  end
end
