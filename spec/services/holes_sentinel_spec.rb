RSpec.describe HoleSentinel do
  let(:referential) { create :workbench_referential }
  let(:workbench) { referential.workbench }
  let(:sentinel) { HoleSentinel.new(workbench) }
  let(:line) { create :line, line_referential: referential.line_referential }
  let(:line2) { create :line, line_referential: referential.line_referential }

  before(:each) do
    workbench.output.update current: referential
    referential.metadatas << create(:referential_metadata, line_ids: [line.id, line2.id], periodes: [(Time.now..1.month.since)])
    allow(referential).to receive(:notifiable_lines).and_return([line, line2])
    referential.switch
  end

  describe '#incoming_holes' do
    subject { sentinel.incoming_holes }
    context 'without stats' do
      it { should be_empty }
    end

    context 'with stats' do
      context 'with no hole' do
        before(:each) do
          1.upto(10).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
        end

        it { should be_empty }
      end

      context 'with a tiny hole' do
        before(:each) do
          1.upto(3).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
          4.upto(5).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 0, line_id: line.id
          end
          6.upto(30).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
        end

        it { should be_empty }
      end

      context 'with a hole' do
        before(:each) do
          1.upto(3).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
          4.upto(9).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 0, line_id: line.id
          end
          10.upto(30).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
        end

        it { should be_present }

        it 'should have a hole for the line with the date' do
          expect(subject[line.id]).to eq 4.days.since.to_date
          expect(subject[line2.id]).to be_nil
        end
      end

      context 'with a hole in the past' do
        before(:each) do
          -20.upto(-10).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
          -9.upto(-3).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 0, line_id: line.id
          end
          -3.upto(30).each do |i|
            Stat::JourneyPatternCoursesByDate.create date: i.day.since.to_date, count: 1, line_id: line.id
          end
        end

        it { should be_empty }
      end
    end
  end
end
