RSpec.describe FootnotesController, :type => :controller do
  login_user permissions: []

  let(:referential) { create :workbench_referential, workbench: workbench, organisation: organisation }
  let(:workbench){ create :workbench, organisation: organisation }
  let(:organisation) { @user.organisation }
  let(:route){ create :route, referential: referential }
  let(:line) { route.line }

  before(:each) do
    line.update line_referential: workbench.line_referential
  end

  describe "GET edit_all" do
    let(:request){ get :edit_all, line_id: line.id, referential_id: referential.id }

    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    with_permission "footnotes.update" do
      it_behaves_like 'checks current_organisation'

      context "with an archived referential" do
        before(:each) do
          referential.archive!
        end
        it 'should respond with 403' do
          expect(request).to have_http_status 403
        end
      end
    end
  end

  describe "PATCH update_all" do
    let(:request){ patch :update_all, line_id: line.id, referential_id: referential.id, line: {footnotes_attributes: {}} }

    it 'should respond with 403' do
      expect(request).to have_http_status 403
    end

    with_permission "footnotes.update" do
      it_behaves_like 'checks current_organisation', success_code: 302
    end
  end
end
