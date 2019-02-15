class Chouette::Netex::ServiceLink < Chouette::Netex::Resource
  def attributes_to_validate
    [{stop_points: :stop_point_lights}]
  end

  def service_link_id(start, finish)
    id_with_entity 'ServiceLink', resource, start, finish
  end

  def build_xml
    resource.stop_point_lights.each_cons(2) do |start, finish|
      costs = resource.costs_between start, finish
      if costs[:time] || costs[:distance]
        @builder.ServiceLink(version: :any, id: service_link_id(start, finish)) do
          if costs[:time]
            @builder.keyList do
              key_value 'EstimatedTime', costs[:time]
            end
          end

          @builder.Distance(costs[:distance]*1000) if costs[:distance]
          ref 'FromPointRef', id_with_entity('ScheduledStopPoint', start)
          ref 'ToPointRef', id_with_entity('ScheduledStopPoint', finish)
        end
      end
    end
  end
end
