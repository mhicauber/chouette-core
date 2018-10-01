RSpec.describe LineReferential, type: :model do
  it 'should have a valid factory' do
    expect(FactoryGirl.build(:line_referential)).to be_valid
  end

  it { should validate_presence_of(:name) }
  it { is_expected.to have_many(:line_referential_syncs) }
  it { is_expected.to have_many(:workbenches) }
  it { should validate_presence_of(:sync_interval) }
  it { should validate_presence_of(:objectid_format) }

  context "#clean_previous_syncs" do
    subject { create :line_referential }

    context "with less than 40 syncs" do
      let(:syncs1) { create_list(:line_referential_sync, 1, line_referential: subject, status: 'successful') }

      before(:each) do
        subject.line_referential_syncs.push(*syncs1)
        subject.save
      end

      it "should remove syncs if there are already 40 or more" do
        expect { subject.clean_previous_syncs(:line_referential_syncs) }.to_not change(LineReferentialSync, :count)
        expect(subject.line_referential_syncs.count).to eq(1)
      end
    end

    context "with more than 40 syncs" do
      let(:syncs50) { create_list(:line_referential_sync, 50, line_referential: subject, status: 'successful') }
      before(:each) do
        subject.line_referential_syncs.push(*syncs50)
        subject.save
      end

      it "should remove syncs if there are already 40 or more" do
        expect { subject.clean_previous_syncs(:line_referential_syncs) }.to change(LineReferentialSync, :count).by(SyncSupport::KEEP_SYNCS - LineReferentialSync.count)
        expect(subject.line_referential_syncs.count).to eq(40)
      end
    end
  end

end
