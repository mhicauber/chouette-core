RSpec.describe Chouette::Netex::ServiceLink, type: :netex_resource do
  let(:resource){ create :journey_pattern, costs: {} }

  it 'should be empty' do
    expect(doc.css("ServiceLink").count).to eq 0
  end

  context 'when cost or distance between 2 stops are filled' do
    before do
      resource.update costs: {
        "#{resource.stop_points[0].stop_area_id}-#{resource.stop_points[1].stop_area_id}" => { time: 12, distance: 10 }
      }
    end

    it 'should create a ServiceLink' do
      expect(doc.children.count).to eq 1
    end

    it 'send the costs' do
      departure = resource.stop_points[0]
      arrival = resource.stop_points[1]

      jp_id = resource.objectid.split(':')[2]
      departure_id = departure.objectid.split(':')[2]
      arrival_id = arrival.objectid.split(':')[2]

      id = "organisation:ServiceLink:#{jp_id}-#{departure_id}-#{arrival_id}:LOC"

      expect(doc.css("ServiceLink[id='#{id}']").count).to eq 1
      expect(doc.css("ServiceLink[id='#{id}'] keyList").count).to eq 1
      expect(doc.css("ServiceLink[id='#{id}'] KeyValue").count).to eq 1
      expect(doc.css("ServiceLink[id='#{id}'] KeyValue Key").count).to eq 1
      expect(doc.css("ServiceLink[id='#{id}'] KeyValue Key").last.text).to eq 'EstimatedTime'
      expect(doc.css("ServiceLink[id='#{id}'] KeyValue Value").count).to eq 1
      expect(doc.css("ServiceLink[id='#{id}'] KeyValue Value").last.text).to eq '12'
      expect(doc.css("ServiceLink[id='#{id}'] Distance").count).to eq 1
      expect(doc.css("ServiceLink[id='#{id}'] Distance").last.text).to eq '10000'
    end

    it_behaves_like 'it has one child with ref', 'FromPointRef', ->{ resource.stop_points[0].objectid.gsub('StopPoint', 'ScheduledStopPoint') }
    it_behaves_like 'it has one child with ref', 'ToPointRef', ->{ resource.stop_points[1].objectid.gsub('StopPoint', 'ScheduledStopPoint') }
  end
end
