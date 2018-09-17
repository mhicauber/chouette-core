RSpec.describe LineReferentialsController, :type => :controller do
  login_user

  let(:line_referential) { create :line_referential }

  before(:each){
    line_referential.organisations << @user.organisation
  }

  describe 'PUT sync' do
    let(:request){ put :sync, id: line_referential.id }

    it 'should respond with 403' do
       expect(request).to have_http_status 403
    end

    with_permission "line_referentials.synchronize" do
      it 'returns HTTP success' do
        expect(request).to redirect_to [line_referential]
      end
    end
  end
end
