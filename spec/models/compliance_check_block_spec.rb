RSpec.describe ComplianceCheckBlock, type: :model do

  subject { build(:compliance_check_block) }

  it { should belong_to :compliance_check_set }
  it { should have_many :compliance_checks }

  it "validates that transport mode and submode are matching" do
    subject.transport_mode = "bus"
    subject.transport_submode = nil

    # BUS -> no submode = OK
    expect(subject).to be_valid

    # BUS -> bus specific submode = OK
    subject.transport_submode = "nightBus"
    expect(subject).to be_valid

    # BUS -> rail specific submode = KO
    subject.transport_submode = "regionalRail"
    expect(subject).not_to be_valid

    # RAIL -> rail specific submode = OK
    subject.transport_mode = "rail"
    expect(subject).to be_valid

    # RAILS -> no submode = KO
    subject.transport_submode = nil
    expect(subject).not_to be_valid
  end
end
