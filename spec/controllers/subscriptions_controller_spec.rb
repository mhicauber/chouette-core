RSpec.describe SubscriptionsController, type: :controller do
  let(:params){{
    user_name: "foo"
  }}

  let(:resource){ assigns(:subscription)}

  describe "POST create" do
    before(:each) do
      allow(Rails.application.config).to receive(:accept_user_creation){ false }
    end

    it "should be not found" do
      post :create, subscription: params
      expect(response).to have_http_status 404
    end

    context "with the feature enabled" do
      before(:each) do
        allow(Rails.application.config).to receive(:accept_user_creation){ true }
      end

      it "should be add errors" do
        post :create, subscription: params
        expect(response).to have_http_status 200
        expect(resource.errors[:email]).to be_present
      end
    end

    context "with all data set" do
      let(:params){{
        organisation_name: "organisation_name",
        user_name: "user_name",
        email: "email@email.com",
        password: "password",
        password_confirmation: "password",
      }}

      before(:each) do
        allow(Rails.application.config).to receive(:accept_user_creation){ true }
      end

      it "should create models and redirect to home" do
        counted = [User, Organisation, LineReferential, StopAreaReferential, Workbench, Workgroup]
        counts = counted.map(&:count)
        post :create, subscription: params

        expect(response).to redirect_to "/"
        counted.map(&:count).each_with_index do |v, i|
          expect(v).to eq(counts[i] + 1), "#{counted[i].t} count is wrong (#{counts[i] + 1} expected, got #{v})"
        end
      end
    end
  end
end
