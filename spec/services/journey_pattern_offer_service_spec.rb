RSpec.describe JourneyPatternOfferService do
  let(:journey_pattern) { create :journey_pattern }
  let(:line) { create :line }
  let(:service) { JourneyPatternOfferService.new(journey_pattern) }
  let(:referential_metadatas_1) do
    create :referential_metadata, line_ids: [line.id], periodes: [(period_start..period_end.prev_day)]
  end
  let(:referential_metadatas_2) do
    create :referential_metadata, line_ids: [line.id], periodes: [(period_start.next..period_end)]
  end
  let(:referential)  { create :workbench_referential, metadatas: [referential_metadatas_1, referential_metadatas_2] }
  let(:period_start) { 1.month.ago.to_date }
  let(:period_end)   { 1.month.since.to_date }

  before(:each) do
    referential.switch
    journey_pattern.route.update line: line
  end

  it 'should detect the timespan' do
    expect(service.period_start).to eq period_start
    expect(service.period_end).to eq period_end
  end

  it 'should detect holes' do
    expect(service.holes).to be_present
    expect(service.holes.first.min).to eq period_start
    expect(service.holes.first.max).to eq period_end
  end

  context 'with a vehicle_journey' do
    let!(:vehicle_journey) { create :vehicle_journey, journey_pattern: journey_pattern, time_tables: time_tables }
    let(:time_tables) { [time_table] }
    let(:time_table) { create :time_table, periods_count: 0, dates_count: 0 }
    let(:circulation_day) { period_start + 10 }

    context 'with a single day of circulation' do
      before do
        time_table.dates.create(date: circulation_day, in_out: true)
      end
      it 'should detect the holes' do
        expect(service.holes).to match_array [
          (period_start...circulation_day),
          (circulation_day.next...period_end.next)
        ]
      end
    end

    context 'with a single day period of circulation' do
      let(:circulation_day) { (period_start + 10.days).beginning_of_week }

      context 'matching application days' do
        before do
          time_table.update int_day_types: ApplicationDaysSupport::MONDAY
          time_table.periods.create!(period_start: circulation_day.prev_day, period_end: circulation_day)
        end

        it 'should detect the holes' do
          expect(service.holes).to match_array [
            (period_start...circulation_day),
            ((circulation_day + 1)...period_end.next)
          ]
        end
      end

      context 'with no hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day)
          time_table.periods.create!(period_start: circulation_day.next, period_end: period_end)
        end

        it 'should not return any hole' do
          expect(service.holes).to match_array []
        end
      end

      context 'with a small hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day.prev_day)
          time_table.periods.create!(period_start: circulation_day.next, period_end: period_end)
        end

        it 'should not return any hole' do
          expect(service.holes).to match_array []
        end
      end

      context 'with a large hole' do
        before do
          time_table.periods.create!(period_start: period_start, period_end: circulation_day - 4)
          time_table.periods.create!(period_start: circulation_day, period_end: period_end)
        end

        it 'should not return any hole' do
          expect(service.holes).to match_array [((circulation_day - 3)...circulation_day)]
        end
      end

      context 'not matching days' do
        before do
          time_table.update int_day_types: ApplicationDaysSupport::ALL_DAYS
          time_table.periods.create!(period_start: circulation_day + 365, period_end: circulation_day + 400)
        end

        it 'should detect the holes' do
          expect(service.holes).to match_array [(period_start...period_end.next)]
        end
      end

      context 'not matching application days' do
        before do
          time_table.update int_day_types: ApplicationDaysSupport::TUESDAY
          time_table.periods.create!(period_start: circulation_day.prev_day, period_end: circulation_day)
        end

        it 'should detect the holes' do
          expect(service.holes).to match_array [(period_start...period_end.next)]
        end
      end
    end
  end
end
