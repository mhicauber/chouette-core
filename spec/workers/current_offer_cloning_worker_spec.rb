require 'spec_helper'
require 'ostruct'

RSpec.describe CurrentOfferCloningWorker do
  let(:referential) { create :workbench_referential }
  let(:current_offer) { create :workbench_referential }
  let(:line_1) { create :line, line_referential: referential.line_referential }
  let(:line_2) { create :line, line_referential: referential.line_referential }
  let(:line_3) { create :line, line_referential: referential.line_referential }

  before(:each) do
    Apartment::Tenant.drop(referential.slug)
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

  describe '#perform', truncation: true do
    let(:new_period_start){ "2020/01/01".to_date }
    let(:new_period_end){ "2020/12/31".to_date }

    before(:each) do
      current_offer.metadatas.create line_ids: [line_1.id], periodes: [((new_period_start-2.months) .. (new_period_start-1.month))]
      current_offer.metadatas.create line_ids: [line_1.id, line_2.id], periodes: [((new_period_start-2.months) .. (new_period_start-1.month)), ((new_period_start-1.week) .. (new_period_end+1.month))]
      current_offer.metadatas.create line_ids: [line_2.id], periodes: [((new_period_start+1.month) .. (new_period_end-1.month))]

      referential.metadatas.create line_ids: [line_1.id], periodes: [(new_period_start..(new_period_end-2.month)), ((new_period_end-1.month)..new_period_end)]
    end

    after(:each) do
      Apartment::Tenant.drop(referential.slug)
      Apartment::Tenant.drop(current_offer.slug)
    end

    it 'should clone the current offer' do
      expect(ReferentialCloning).to receive(:new).with(
        source_referential: current_offer, target_referential: referential
      ).and_call_original

      expect_any_instance_of(ReferentialCloning).to receive(:clone!)

      CurrentOfferCloningWorker.new.perform(referential.id)
    end

    it 'should filter the metadatas' do
      CurrentOfferCloningWorker.new.perform(referential.id)

      referential.reload
      expect(referential.metadatas.size).to eq 1
      metadata = referential.metadatas.last
      expect(metadata.line_ids).to eq [line_1.id]
      expect(metadata.periodes).to eq [(new_period_start..new_period_end)]
    end

    it 'should clean the data' do
      expect(CleanUp).to receive(:new).with(referential: referential).and_call_original
      expect(CleanUp).to receive(:new).with(referential: referential, begin_date: new_period_start, date_type: :before).and_call_original
      expect(CleanUp).to receive(:new).with(referential: referential, end_date: new_period_end, date_type: :after).and_call_original
      expect(CleanUp).to receive(:new).with(referential: referential, methods: [:destroy_empty, :destroy_unassociated_calendars]).and_call_original

      CurrentOfferCloningWorker.new.perform(referential.id)
    end
  end
end
