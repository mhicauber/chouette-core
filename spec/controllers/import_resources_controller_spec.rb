RSpec.describe ImportResourcesController, :type => :controller do
  login_user

  let(:organisation){ @user.organisation }
  let(:workbench) { create :workbench, organisation: organisation }
  let(:import)    { create :import, workbench: workbench }
  let(:import_resource)    { create :import_resource, import: import }

  describe "GET index" do
    let(:request){ get :index, workbench_id: workbench.id, import_id: import.id }
    it_behaves_like 'checks current_organisation'
  end

  describe "GET show" do
    let(:request){ get :show, workbench_id: workbench.id, import_id: import.id, id: import_resource.id }
    it_behaves_like 'checks current_organisation'
  end
end
