require 'rails_helper'

RSpec.describe Workgroup, type: :model do
  context "associations" do
    let(:stop_area_referential) { build_stubbed :stop_area_referential }
    let(:line_referential) { build_stubbed :line_referential }

    let(:workgroup){ build_stubbed :workgroup, line_referential: line_referential, stop_area_referential: stop_area_referential }

    it{ should have_many(:workbenches) }
    it{ should validate_uniqueness_of(:name) }
    it{ should validate_uniqueness_of(:stop_area_referential_id) }
    it{ should validate_uniqueness_of(:line_referential_id) }

    it 'is not valid without a stop_area_referential' do
      workgroup.stop_area_referential = nil
      expect( workgroup ).not_to be_valid
    end
    it 'is not valid without a line_referential' do
      workgroup.line_referential = nil
      expect( workgroup ).not_to be_valid
    end
    it 'is valid with both associations' do
      expect(workgroup).to be_valid
    end
  end

  context "find organisations" do
    let( :workgroup ){ create :workgroup }
    let!( :workbench1 ){ create :workbench, workgroup: workgroup }
    let!( :workbench2 ){ create :workbench, workgroup: workgroup }

    it{ expect( Set.new(workgroup.organisations) ).to eq(Set.new([ workbench1.organisation, workbench2.organisation ])) }
  end

  describe "#nightly_aggregate_timeframe?" do
    let(:workgroup) { create(:workgroup) }

    context "when nightly_aggregate_enabled is true" do
      before do
        workgroup.nightly_aggregate_enabled = true
      end

      it "returns true when inside timeframe" do
        Timecop.freeze(Time.current.beginning_of_day) do
          expect(workgroup.nightly_aggregate_timeframe?).to be_truthy
        end
      end

      it "returns false when outside timeframe" do
        Timecop.freeze(Time.current.beginning_of_day + 2.hours) do
          expect(workgroup.nightly_aggregate_timeframe?).to be_falsy
        end
      end

      it "returns false when inside timeframe but already done" do
        workgroup.nightly_aggregated_at = Time.current.beginning_of_day
        Timecop.freeze(Time.current.beginning_of_day + 3.minutes) do
          expect(workgroup.nightly_aggregate_timeframe?).to be_falsy
        end
      end
    end

    context "when nightly_aggregate_enabled is false" do
      it "is false even within timeframe" do
        Timecop.freeze(Time.current.beginning_of_day) do
          expect(workgroup.nightly_aggregate_timeframe?).to be_falsy
        end
      end
    end
  end

  describe "#nightly_aggregate!" do
    let(:workgroup) { create(:workgroup, nightly_aggregate_enabled: true) }

    context "when no aggregatable referential is found" do
      it "returns with a log message" do
        Timecop.freeze(Time.current.beginning_of_day) do
          expect(Rails.logger).to receive(:info).with(/\ANo aggregatable referential found/)

          expect { workgroup.nightly_aggregate! }.not_to change {
            workgroup.aggregates.count
          }
        end
      end
    end

    context "when we have rollbacked to a previous aggregate" do
      let(:workbench) { create(:workbench, workgroup: workgroup) }
      let(:referential) { create(:referential, organisation: workbench.organisation) }
      let(:aggregatable) { create(:workbench_referential, workbench: workbench) }
      let(:referential_2) { create(:referential, organisation: workbench.organisation) }
      let(:aggregate) { create(:aggregate, workgroup: workgroup)}
      let(:aggregate_2) { create(:aggregate, workgroup: workgroup)}
      let(:referential_suite) { create(:referential_suite, current: aggregatable) }
      let(:workgroup_referential_suite) { create(:referential_suite, current: referential_2, referentials: [referential, referential_2]) }

      before do
        aggregate.update new: referential
        aggregatable
        aggregate_2.update new: referential_2
        
        workbench.update(output: referential_suite)
        workgroup.update(output: workgroup_referential_suite)
        aggregate.rollback!
        expect(workgroup.output.current).to eq referential
      end

      it "returns with a log message" do
        Timecop.freeze(Time.current.beginning_of_day) do
          expect(Rails.logger).to receive(:info).with(/\ANo aggregatable referential found/)

          expect { workgroup.nightly_aggregate! }.not_to change {
            workgroup.aggregates.count
          }
        end
      end
    end

    context "when aggregatable referentials are found" do
      let(:workbench) { create(:workbench, workgroup: workgroup) }
      let(:referential) { create(:referential, organisation: workbench.organisation, workbench: workbench) }
      let(:referential_suite) { create(:referential_suite, current: referential) }

      before do
        workbench.update(output: referential_suite)
      end

      it "creates a new aggregate" do
        Timecop.freeze(Time.current.beginning_of_day) do
          expect { referential.workgroup.nightly_aggregate! }.to change {
            referential.workgroup.aggregates.count
          }.by(1)
          expect(referential.workgroup.aggregates.where(creator: 'CRON')).to exist
        end
      end
    end
  end
end
