RSpec.describe Api::V1::Internals::NetexImportsController, type: :controller do
  let(:import_1) { create :netex_import }
  let(:import_2) { create :netex_import, status: "successful" }

  describe "GET #notify_parent" do
    context 'unauthenticated' do
      include_context 'iboo wrong authorisation internal api'

      it 'should not be successful' do
        get :notify_parent, id: import_1.id, format: :json
        expect(response).to have_http_status 401
      end
    end

    context 'authenticated' do
      include_context 'iboo authenticated internal api'

      describe "with existing record" do

        before(:each) do
          get :notify_parent, id: import_2.id, format: :json
        end

        it 'should be successful' do
          expect(response).to have_http_status 200
        end

        it "calls #notify_parent on the import" do
          expect(import_2.reload.notified_parent_at).not_to be_nil
        end
      end

      describe "with non existing record" do
        it "should throw an error" do
          get :notify_parent, id: 47, format: :json
          expect(response.body).to include("error")
        end
      end
    end
  end
end
