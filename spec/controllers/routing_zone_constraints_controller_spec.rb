RSpec.describe RoutingConstraintZonesController, :type => :controller do
  login_user

  let(:route) { create(:route, referential: referential) }
  let!(:rcz)   { create(:routing_constraint_zone, route: route, name: 'name') }
  let(:q)     { {} }

  describe 'GET index' do
    let(:request){ get :index, referential_id: referential.id, line_id: route.line_id, q: q }

    before(:each){ referential.update objectid_format: :netex }

    context 'without filter' do
      it 'should include the rcz' do
        expect(request).to be_success
        expect(assigns(:routing_constraint_zones)).to include rcz
      end
    end

    context 'with a name filter' do
      let(:q) { { name_or_short_id_cont: 'foo', route_id_eq: '' } }
      it 'should not include the rcz' do
        expect(request).to be_success
        expect(assigns(:routing_constraint_zones)).to_not include rcz
      end
    end
  end
end
