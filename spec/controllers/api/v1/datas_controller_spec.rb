require 'rails_helper'

RSpec.describe Api::V1::DatasController, type: :controller do
  let(:file){ File.open(File.join(Rails.root, 'spec', 'fixtures', 'google-sample-feed.zip')) }
  let(:export){ create :gtfs_export, status: :successful, file: file}
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

  context 'when needing authentication' do
    let(:auth_token) { 'token' }

    before do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
    end

    describe 'get #download_full' do
      let(:slug) { :foo }
      let(:key) { :foo }
      let(:get_request) { get :download_full, slug: slug, key: key }

      it 'should not be successful' do
        expect{ get_request }.to raise_error ActiveRecord::RecordNotFound
      end

      context 'with a publication_api' do
        let(:publication_api) { create(:publication_api) }
        let(:publication_api_key) { create :publication_api_key }
        let(:auth_token) { publication_api_key.token }

        let(:slug) { publication_api.slug }

        it 'should not be successful' do
          get_request
          expect(response).to_not be_success
        end

        context 'with a publication_api_source' do
          before(:each) do
            create :publication_api_source, publication_api: publication_api, key: key, export: export
          end

          it 'should not be successful' do
            get_request
            expect(response).to_not be_success
          end

          context 'authenticated' do
            let(:publication_api_key) { create :publication_api_key, publication_api: publication_api }

            it 'should be successful' do
              get_request
              expect(response).to be_success
            end
          end
        end
      end
    end

    describe 'get #download_line' do
      let(:slug) { :foo }
      let(:key) { :foo }
      let(:line_id) { :foo }
      let(:get_request) { get :download_line, slug: slug, key: key, line_id: line_id }

      it 'should not be successful' do
        expect{ get_request }.to raise_error ActiveRecord::RecordNotFound
      end

      context 'with a publication_api' do
        let(:publication_api) { create(:publication_api) }
        let(:publication_api_key) { create :publication_api_key }
        let(:auth_token) { publication_api_key.token }

        let(:slug) { publication_api.slug }

        it 'should not be successful' do
          get_request
          expect(response).to_not be_success
        end

        context 'with a publication_api_source' do
          before(:each) do
            create :publication_api_source, publication_api: publication_api, key: "#{key}-#{line_id}", export: export
          end

          it 'should not be successful' do
            get_request
            expect(response).to_not be_success
          end

          context 'authenticated' do
            let(:publication_api_key) { create :publication_api_key, publication_api: publication_api }

            it 'should be successful' do
              get_request
              expect(response).to be_success
            end
          end
        end
      end
    end
  end
end
