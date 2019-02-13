RSpec.describe Chouette::Netex::Line, type: :netex_resource do
  let(:resource){ create :line, transport_submode: :demandAndResponseBus }

  it_behaves_like 'it has default netex resource attributes', { status: 'active' }

  it_behaves_like 'it has children matching attributes', {
    'Name' => :published_name,
    'Url' => :url,
    'PublicCode' => :number,
    'PrivateCode' => :registration_number,
    'TransportMode' => :transport_mode,
    'TransportSubmode BusSubmode' => :transport_submode,
  }

  it_behaves_like 'it has one child with ref', 'OperatorRef', ->{ resource.company.objectid }
  it_behaves_like 'it has one child with ref', 'RepresentedByGroupRef', ->{ resource.network.objectid }
  it_behaves_like 'it has no child', 'additionalOperators'

  context 'with a secondary company' do
    let(:secondary){ create(:company) }
    before(:each) do
      resource.update secondary_companies: [secondary]
    end

    it_behaves_like 'it has one child with ref', 'additionalOperators OperatorRef', ->{ secondary.objectid }
  end
end
