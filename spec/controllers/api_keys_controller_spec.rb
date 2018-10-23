RSpec.describe ApiKeysController, :type => :controller do
  let(:workbench){ create :workbench, organisation: organisation }

  describe "GET index" do
    let(:request) { get :index, workbench_id: workbench.id }

    context "with permission api_keys.index" do
      login_user permissions: %w{api_keys.index}

      it_behaves_like 'checks current_organisation'
    end

    context "without permission api_keys.index" do
      login_user permissions: []

      it "avoid access" do
        expect(request).to have_http_status 403
      end
    end
  end

end
