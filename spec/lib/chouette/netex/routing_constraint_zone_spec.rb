RSpec.describe Chouette::Netex::RoutingConstraintZone , type: :netex_resource do
  let(:resource){ create :routing_constraint_zone }

  it_behaves_like 'it has default netex resource attributes'

  it_behaves_like 'it has children matching attributes', {
    'Name' => :name
  }

  it_behaves_like 'it has one child with ref', 'lines LineRef', ->{ resource.route.line.objectid }
  it_behaves_like 'it has one child with value', 'keyList KeyValue Key', 'routeRef'
  it_behaves_like 'it has one child with value', 'keyList KeyValue Value', ->{ resource.route.objectid }
  it_behaves_like 'it has one child with value', 'ZoneUse', 'cannotBoardAndAlightInSameZone'

  it 'should have members' do
    expect(node.css('members ScheduledStopPointRef').count).to eq resource.stop_points.count
    resource.stop_points.each do |sp|
      ref = sp.objectid.gsub('StopPoint', 'ScheduledStopPoint')
      expect(node.css("members ScheduledStopPointRef[ref='#{ref}']").count).to eq 1
    end
  end
end
