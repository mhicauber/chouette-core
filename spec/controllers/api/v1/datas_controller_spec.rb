require 'rails_helper'

RSpec.describe Api::V1::DatasController, type: :controller do
  context 'unauthenticated' do

    describe 'GET #info' do
      it 'should not be successful' do
        expect{ get :infos, slug: :foo }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'with a publication_api' do
      it 'should be successful' do
        get :infos, slug: create(:publication_api).slug
        expect(response).to be_success
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
