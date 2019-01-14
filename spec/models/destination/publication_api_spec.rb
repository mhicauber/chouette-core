require 'rails_helper'

RSpec.describe Destination::PublicationApi, type: :model do
  let(:publication_api) { create :publication_api }
  let(:publication_setup) { create :publication_setup }
  let(:other_publication_setup) { create :publication_setup, export_type: publication_setup.export_type, export_options: publication_setup.export_options }
  let(:destination) { build :destination, type: Destination::PublicationApi, publication_setup: publication_setup, publication_api: publication_api }

  it 'should be valid' do
    expect(destination).to be_valid
  end

  context 'when another PublicationSetup of same kind already publishes to that API' do
    before do
      create :destination, type: Destination::PublicationApi, publication_setup: other_publication_setup, publication_api: publication_api
    end

    it 'should not be valid' do
      expect(destination).to_not be_valid
      expect(destination.errors[:publication_api_id]).to be_present
    end
  end
end
