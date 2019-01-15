require 'rails_helper'

RSpec.describe PublicationApi, type: :model do
  subject { create(:publication_api) }

  it { should belong_to :workgroup }
  it { should validate_presence_of :name }
  it { should validate_presence_of :slug }
  it { should validate_uniqueness_of :slug }

  let(:valid_slugs){ %w[demo demo2 demo_2]}
  let(:invalid_slugs){ ["demo 1", "démo"] }

  it 'validates slug format' do
    valid_slugs.each do |slug|
      subject.slug = slug
      expect(subject).to be_valid
    end

    invalid_slugs.each do |slug|
      subject.slug = slug
      expect(subject).to_not be_valid
    end
  end

  context '#publication_for_export_type' do
    let(:publication_api) { create :publication_api }
    let(:export_type) { 'Export::Netex' }
    let(:export_options) { { export_type: :full } }
    let(:publication_setup) { create :publication_setup, export_type: export_type, export_options: export_options }
    let(:other_publication_setup) { create :publication_setup, export_type: export_type, export_options: {foo: 'bar'} }
    let(:publication) { create :publication, publication_setup: publication_setup }
    let(:other_publication) { create :publication, publication_setup: other_publication_setup }

    it 'should be nil by default' do
      expect(publication_api.publication_for_export_type(export_type, export_options)).to be_nil
    end

    context 'with no matching publication' do
      before do
        publication_api.publications << other_publication
      end

      it 'should be nil' do
        expect(publication_api.publication_for_export_type(export_type, export_options)).to be_nil
      end
    end

    context 'with a matching publication' do
      before do
        publication_api.publications << other_publication
        publication_api.publications << publication
      end

      it 'should find it' do
        expect(publication_api.publication_for_export_type(export_type, export_options)).to eq publication
      end

      context 'with several matching publication' do
        let(:other_publication) { create :publication, publication_setup: publication_setup }

        it 'should take the latest' do
          expect(publication_api.publication_for_export_type(export_type, export_options)).to eq publication
        end
      end
    end
  end
end
