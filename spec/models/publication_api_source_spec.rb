require 'rails_helper'

RSpec.describe PublicationApiSource, type: :model do
  subject { create(:publication_api_source) }

  it { should belong_to :publication_api }
  it { should belong_to :publication }

  let(:publication_api_source) { build :publication_api_source, export: nil }
  let(:line) { create :line }

  context '#generate_key' do
    it 'should generate correctly' do
      expect(publication_api_source.send(:generate_key)).to be_nil

      publication_api_source.export = build :gtfs_export
      expect(publication_api_source.send(:generate_key)).to eq 'gtfs'

      publication_api_source.export = build :netex_export, export_type: 'line', line_code: line.id
      expect(publication_api_source.send(:generate_key)).to eq "netex-line-#{line.code}"

      publication_api_source.export = build :netex_export, export_type: 'full'
      expect(publication_api_source.send(:generate_key)).to eq 'netex-full'
    end
  end
end
