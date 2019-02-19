RSpec.describe WorkgroupsController, :type => :controller do
  login_user

  let(:workbench) { create :workbench, organisation: organisation }
  let(:workgroup) { workbench.workgroup }
  let(:organisation){ @user.organisation }
  let(:compliance_control_set) { create :compliance_control_set, organisation: organisation }
  let(:merge_id) { 2**64/2 - 1 } # Let's check we support Bigint

  describe "GET show" do
    let(:request){ get :show, id: workgroup.id }
    it_behaves_like 'checks current_organisation'
  end

  describe "GET edit_controls" do
    let(:request){ get :edit_controls, id: workgroup.id }
    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end
    context "when belonging to the owner" do
      before do
        workgroup.update owner: @user.organisation
      end
      it_behaves_like 'checks current_organisation'
    end
  end

  describe 'PUT create' do
    let(:params){
      {
        workgroup: { name: "Foo" }
      }
    }
    let(:request){ put :create, params }

    without_permission "workgroups.create" do
      it 'should respond with 403' do
        expect(request).to have_http_status 403
      end
    end

    with_permission "workgroups.create" do
      it 'should create a new Workgroup' do
        expect{ request }.to change{ Workgroup.count }.by 1
      end

      it 'should create a new Workbench' do
        expect{ request }.to change{ Workbench.count }.by 1
      end

      it 'should create a new LineReferential' do
        expect{ request }.to change{ LineReferential.count }.by 1
      end

      it 'should create a new LineReferential' do
        expect{ request }.to change{ StopAreaReferential.count }.by 1
      end

      context "with an error" do
        before { create :workgroup, name: "Foo" }
        it 'should respond with 200' do
          expect(request).to have_http_status 200
        end

        it 'should not create a new Workbench' do
          expect{ request }.to_not change{ Workbench.count }
        end

        it 'should not create a new LineReferential' do
          expect{ request }.to_not change{ LineReferential.count }
        end

        it 'should not create a new LineReferential' do
          expect{ request }.to_not change{ StopAreaReferential.count }
        end
      end
    end
  end

  describe 'PATCH update_controls' do
    let(:params){
      {
        id: workgroup.id,
        workgroup: {
          workbenches_attributes: {
            "0" => {
              id: workbench.id,
              compliance_control_set_ids: {
                after_import_by_workgroup: compliance_control_set.id,
                after_merge_by_workgroup: merge_id
              }
            }
          }
        }
      }
    }
    let(:request){ patch :update_controls, params }

    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    context "when belonging to the owner" do
      before do
        workgroup.update owner: @user.organisation
      end
      it 'returns HTTP success' do
        expect(request).to be_redirect
        expect(workbench.reload.compliance_control_set(:after_import_by_workgroup)).to eq compliance_control_set
        expect(workbench.reload.owner_compliance_control_set_ids['after_merge_by_workgroup']).to eq merge_id.to_s
      end
    end
  end
end
