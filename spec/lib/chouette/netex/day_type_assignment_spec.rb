RSpec.describe Chouette::Netex::DayTypeAssignment , type: :netex_resource do
  let(:resource){ create :time_table, :empty }

  it 'should be empty' do
    expect(doc.css('OperatingPeriod').count).to eq 0
  end

  context 'with periods and dates' do
    let(:resource){ create :time_table, dates_count: 0 }

    before(:each) do
      resource.dates << create(:time_table_date, time_table: resource, :date => 1.days.since.to_date, in_out: true)
      resource.dates << create(:time_table_date, time_table: resource, :date => 2.days.since.to_date, in_out: false)
    end

    it 'should have DayTypeAssignments' do
      expect(doc.css('DayTypeAssignment').count).to eq 6

      tt_id = resource.objectid.split(':')[2]
      (1..resource.periods.count).each do |i|
        id = "organisation:DayTypeAssignment:#{tt_id}-#{i}:LOC"
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}']").count).to eq(1), "Found no DayTypeAssignment with ID #{id} in\n#{doc.to_xml}"
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] Date").count).to eq 0
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] OperatingPeriodRef").count).to eq 1
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] OperatingPeriodRef").last[:ref]).to eq "organisation:OperatingPeriod:#{tt_id}-#{i}:LOC"
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] DayTypeRef").count).to eq 1
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] DayTypeRef").last[:ref]).to eq resource.objectid
      end
    end

    it 'should have DayTypeAssignments' do
      tt_id = resource.objectid.split(':')[2]

      (5..6).each do |i|
        id = "organisation:DayTypeAssignment:#{tt_id}-#{i}:LOC"
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}']").count).to eq(1), "Found no DayTypeAssignment with ID #{id} in\n#{doc.to_xml}"
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] OperatingPeriodRef").count).to eq 0
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] Date").count).to eq 1
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] DayTypeRef").count).to eq 1
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] DayTypeRef").last[:ref]).to eq resource.objectid
        expect(doc.css("DayTypeAssignment[id='#{id}'][order='#{i}'] isAvailable").count).to eq i == 5 ? 0 : 1
      end
    end
  end
end
