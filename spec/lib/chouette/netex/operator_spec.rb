RSpec.describe Chouette::Netex::Operator, type: :netex_resource do
  let(:resource){ create :company }
  let(:workgroup){ create :workgroup, line_referential: resource.line_referential }

  it_behaves_like 'it has default netex resource attributes'

  it_behaves_like 'it outputs custom fields'

  it_behaves_like 'it has children matching attributes', {
    'PublicCode' => :code,
    'CompanyNumber' => :registration_number,
    'Name' => :name,
    'ShortName' => :short_name,
    'ContactDetails > Email' => :email,
    'ContactDetails > Phone' => :phone,
    'ContactDetails > Url' => :url
  }

  context 'without contact attributes' do
    before(:each) do
      resource.update email: nil, phone: nil, url: nil
    end
    it_behaves_like 'it has no child', 'ContactDetails'
  end
end
