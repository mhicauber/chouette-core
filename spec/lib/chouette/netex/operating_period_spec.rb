RSpec.describe Chouette::Netex::OperatingPeriod , type: :netex_resource do
  let(:resource){ create :time_table, :empty }

  it 'should be empty' do
    expect(doc.css('OperatingPeriod').count).to eq 0
  end

  context 'with periods' do
    let(:resource){ create :time_table }

    it 'should have OperatingPeriods' do
      expect(doc.css('OperatingPeriod').count).to eq resource.periods.count

      tt_id = resource.objectid.split(':')[2]
      (1..resource.periods.count).each do |i|
        id = "organisation:OperatingPeriod:#{tt_id}-#{i}:LOC"
        expect(doc.css("OperatingPeriod[id='#{id}']").count).to eq(1), "Found no OperatingPeriod with ID #{id} in\n#{doc.to_xml}"
        expect(doc.css("OperatingPeriod[id='#{id}'] FromDate").count).to eq 1
        expect(doc.css("OperatingPeriod[id='#{id}'] ToDate").count).to eq 1
      end
    end
  end

end
