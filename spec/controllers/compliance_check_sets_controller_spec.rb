RSpec.describe ComplianceCheckSetsController, :type => :controller do
  login_user

  let(:organisation){ @user.organisation }
  let(:workbench) { create :workbench, organisation: organisation }
  let(:ccset) { create :compliance_check_set, workbench: workbench }

  describe "GET index" do
    let(:request){ get :index, workbench_id: workbench.id }
    it_behaves_like 'checks current_organisation'
  end

  describe "GET executed" do
    let(:request){ get :index, workbench_id: workbench.id, id: ccset.id }
    it_behaves_like 'checks current_organisation'
  end
end
