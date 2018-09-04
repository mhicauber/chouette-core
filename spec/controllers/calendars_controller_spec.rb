RSpec.describe CalendarsController, :type => :controller do
  login_user permissions: []
  let(:workbench){ create :workbench, organisation: organisation }
  let(:workgroup){ workbench.workgroup }

  describe "GET index" do
    let(:request){ get :index, workgroup_id: workgroup.id }
    it_behaves_like 'checks current_organisation'
  end
end
