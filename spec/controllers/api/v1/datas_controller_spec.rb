require 'rails_helper'

RSpec.describe Api::V1::DatasController, type: :controller do
  let(:file){ File.open(File.join(Rails.root, 'spec', 'fixtures', 'google-sample-feed.zip')) }

  describe 'GET #info' do
    it 'should not be successful' do
      expect{ get :infos, slug: :foo }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'with a publication_api' do
      it 'should be successful' do
        get :infos, slug: create(:publication_api).slug
        expect(response).to be_success
      end
    end
  end

  describe 'get #download_full' do
    let(:slug) { :foo }
    let(:key) { :foo }
    let(:request) { get :download_full, slug: slug, key: key }

    it 'should not be successful' do
      expect{ request }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'with a publication_api' do
      let(:publication_api) { create(:publication_api) }
      let(:slug) { publication_api.slug }

      it 'should not be successful' do
        expect{ request }.to raise_error ActiveRecord::RecordNotFound
      end

      context 'with a publication_api_source' do
        before(:each) do
          create :publication_api_source, publication_api: publication_api, key: key, file: file
        end

        it 'should be successful' do
          request
          expect(response).to be_success
        end
      end
    end
  end



  # context 'authenticated' do
  #   include_context 'iboo authenticated api user'
  #
  #   describe 'GET #index' do
  #     it 'should be successful' do
  #       get :index, workbench_id: workbench.id, format: :json
  #       expect(response).to be_success
  #     end
  #   end
  #
  #   describe 'POST #create' do
  #     let(:file) { fixture_file_upload('multiple_references_import.zip') }
  #
  #     it 'should be successful' do
  #       expect {
  #         post :create, {
  #           workbench_id: workbench.id,
  #           workbench_import: {
  #             name: "test",
  #             file: file,
  #             creator: 'test',
  #             options: {
  #               "automatic_merge": true
  #             }
  #           },
  #           format: :json
  #         }
  #       }.to change{Import::Workbench.count}.by(1)
  #       expect(response).to be_success
  #       expect(Import::Workbench.last.automatic_merge).to be_truthy
  #     end
  #   end
  # end
end
