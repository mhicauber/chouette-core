class Chouette::Netex::RoutePoint < Chouette::Netex::Resource
  def resource_metas
    {
      version: :any,
      id: id_with_entity('RoutePoint', resource),
    }
  end

  def build_xml
    @builder.RoutePoint(resource_metas) do
      @builder.projections do
        @builder.PointProjection(version: :any, id: id_with_entity('PointProjection', resource)) do
          ref 'ProjectToPointRef', id_with_entity('ScheduledStopPoint', resource)
        end
      end
    end
  end
end
