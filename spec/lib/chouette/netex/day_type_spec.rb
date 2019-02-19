RSpec.describe Chouette::Netex::DayType, type: :netex_resource do
  let(:resource){ create :time_table, int_day_types: (1..5).to_a.map{ |n| 2**(n+1) }.sum }
  it_behaves_like 'it has default netex resource attributes'

  it_behaves_like 'it has no child', 'keyList'

  context 'with tags' do
    before { resource.update tag_list: %w{foo bar} }

    it 'should fill the keyList' do
      expect(node.css('keyList KeyValue').count).to eq 1
      expect(node.css('keyList KeyValue Key').last.text).to eq 'Tags'
      expect(node.css('keyList KeyValue Value').last.text).to eq 'bar,foo'
    end
  end

  context 'with color' do
    before { resource.update color: '#cccccc' }

    it 'should fill the keyList' do
      expect(node.css('keyList KeyValue').count).to eq 1
      expect(node.css('keyList KeyValue Key').last.text).to eq 'Colour'
      expect(node.css('keyList KeyValue Value').last.text).to eq '#cccccc'
    end
  end

  it_behaves_like 'it has children matching attributes', { 'Name' => :comment }
  it_behaves_like 'it has one child with value', 'properties PropertyOfDay DaysOfWeek', 'Monday Tuesday Wednesday Thursday Friday'
end
