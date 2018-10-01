require 'rails_helper'

RSpec.describe StopAreaReferential, :type => :model do
  it 'should have a valid factory' do
    expect(FactoryGirl.build(:stop_area_referential)).to be_valid
  end

  it { is_expected.to have_many(:stop_area_referential_syncs) }
  it { is_expected.to have_many(:workbenches) }
  it { should validate_presence_of(:objectid_format) }
  it { should allow_value('').for(:registration_number_format) }
  it { should allow_value('X').for(:registration_number_format) }
  it { should allow_value('XXXXX').for(:registration_number_format) }
  it { should_not allow_value('123').for(:registration_number_format) }
  it { should_not allow_value('ABC').for(:registration_number_format) }

  context "#clean_previous_syncs" do
    subject { create :stop_area_referential }

    context "with less than 40 syncs" do
      let(:syncs1) { create_list(:stop_area_referential_sync, 1, stop_area_referential: subject, status: 'successful') }

      before(:each) do
        subject.stop_area_referential_syncs.push(*syncs1)
        subject.save
      end

      it "should remove syncs if there are already 40 or more" do
        expect { subject.clean_previous_syncs(:stop_area_referential_syncs) }.to_not change(StopAreaReferentialSync, :count)
        expect(subject.stop_area_referential_syncs.count).to eq(1)
      end
    end

    context "with more than 40 syncs" do
      let(:syncs50) { create_list(:stop_area_referential_sync, 50, stop_area_referential: subject, status: 'successful') }
      before(:each) do
        subject.stop_area_referential_syncs.push(*syncs50)
        subject.save
      end

      it "should remove syncs if there are already 40 or more" do
        expect { subject.clean_previous_syncs(:stop_area_referential_syncs) }.to change(StopAreaReferentialSync, :count).by(SyncSupport::KEEP_SYNCS - StopAreaReferentialSync.count)
        expect(subject.stop_area_referential_syncs.count).to eq(40)
      end
    end
  end
end
