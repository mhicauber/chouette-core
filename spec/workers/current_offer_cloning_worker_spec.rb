require 'spec_helper'
require 'ostruct'

RSpec.describe CurrentOfferCloningWorker do
  let(:referential) { create :workbench_referential }
  let(:current_offer) { create :workbench_referential }
  let(:line_1) { create :line, line_referential: referential.line_referential }
  let(:line_2) { create :line, line_referential: referential.line_referential }
  let(:line_3) { create :line, line_referential: referential.line_referential }
  let(:timetable_1) { create :time_table }
  let(:timetable_2) { create :time_table }
  let(:purchase_window_1) { create :purchase_window }
  let(:purchase_window_2) { create :purchase_window }

  before(:each) do
    current_offer.update referential_suite: referential.workbench.output
    referential.workbench.output.update current: current_offer
  end

  describe '#fill_from_current_offer' do
    it 'should mark the referential as pending' do
      expect(referential.state).to_not eq :pending
      expect(CurrentOfferCloningWorker).to receive(:perform_async)

      CurrentOfferCloningWorker.fill_from_current_offer referential

      expect(referential.state).to eq :pending
    end
  end

  describe '#perform' do
    let(:new_period_start){ "2020/01/01".to_date }
    let(:new_period_end){ "2020/12/31".to_date }

    before(:each) do
      current_offer.metadatas.create line_ids: [line_1.id], periodes: [((new_period_start-2.months) .. (new_period_start-1.month))]
      current_offer.metadatas.create line_ids: [line_1.id, line_2.id], periodes: [((new_period_start-2.months) .. (new_period_start-1.month)), ((new_period_start-1.week) .. (new_period_end+1.month))]
      current_offer.metadatas.create line_ids: [line_2.id], periodes: [((new_period_start+1.month) .. (new_period_end-1.month))]
      current_offer.switch do
        3.times { create :route, line: line_1 }
        3.times { create :route, line: line_2 }
        create :vehicle_journey, journey_pattern: line_1.routes.last.full_journey_pattern, time_tables: [timetable_1], purchase_windows: [purchase_window_1]
        create :vehicle_journey, journey_pattern: line_2.routes.last.full_journey_pattern, time_tables: [timetable_2], purchase_windows: [purchase_window_2]
      end

      referential.metadatas.create line_ids: [line_1.id], periodes: [(new_period_start..(new_period_end-2.month)), ((new_period_end-1.month)..new_period_end)]
    end

    it 'should clone the current offer' do
      expect(ReferentialCopy).to receive(:new).with(
        source: current_offer, target: referential, skip_metadatas: true, lines: [line_1]
      ).and_call_original

      expect_any_instance_of(ReferentialCopy).to receive(:copy!)

      CurrentOfferCloningWorker.new.perform(referential.id)
    end

    it 'should keep the metadatas' do
      current_offer = referential.workbench.output.current
      current_offer.metadatas.destroy_all
      CurrentOfferCloningWorker.new.perform(referential.id)

      referential.reload
      expect(referential.metadatas.size).to eq 1
      metadata = referential.metadatas.last
      expect(metadata.line_ids).to eq [line_1.id]
      expect(metadata.periodes).to eq [(new_period_start..(new_period_end-2.month)), ((new_period_end-1.month)..new_period_end)]
    end

    it 'should copy the datas' do
      CurrentOfferCloningWorker.new.perform(referential.id)

      referential.switch
      expect(Chouette::PurchaseWindow.count).to eq 1
      expect(Chouette::TimeTable.count).to eq 1
      expect(Chouette::Route.count).to eq 3
    end
  end
end
