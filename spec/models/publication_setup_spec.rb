require 'rails_helper'

RSpec.describe PublicationSetup, type: :model do
  it { should belong_to :workgroup }
  it { should have_many :destinations }
  it { should have_many :publications }
  it { should validate_presence_of :name }
  it { should validate_presence_of :workgroup }
  it { should validate_presence_of :export_type }

  describe '#publish' do
    let(:publication_setup) { create :publication_setup }
    let(:referential) { create :referential }
    let(:operation) { create :aggregate, new: referential }

    it 'should create a Publication' do
      expect_any_instance_of(Publication).to receive(:publish)
      expect{ publication_setup.publish(referential) }.to change{ publication_setup.publications.count }.by 1
    end
  end
end
