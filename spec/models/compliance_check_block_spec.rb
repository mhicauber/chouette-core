RSpec.describe ComplianceCheckBlock, type: :model do

  subject { build(:compliance_check_block) }

  it { should belong_to :compliance_check_set }
  it { should have_many :compliance_checks }

  it "validates that condition_attributes are consistent" do
    subject.transport_mode = "bus"
    subject.transport_submode = nil
    subject.block_kind = nil

    # No block_kind => KO
    expect(subject).to_not be_valid

    subject.block_kind = "transport_mode"
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

    subject.block_kind = "stop_areas_in_countries"
    expect(subject).to_not be_valid

    subject.country = "fr"
    expect(subject).to_not be_valid

    subject.min_stop_areas_in_country = "2"
    expect(subject).to be_valid
  end

  describe '#lines_scope' do
    let(:compliance_check_set){ build_stubbed :compliance_check_set, referential: referential }

    let!(:generic_line) { create :line, line_referential: referential.line_referential, transport_mode: nil }
    let!(:bus_line) { create :line, line_referential: referential.line_referential, transport_mode: :bus }
    let!(:nightBus_line) { create :line, line_referential: referential.line_referential, transport_mode: :bus, transport_submode: :nightBus }
    let!(:fr_line) { create :line, line_referential: referential.line_referential, transport_mode: nil }
    let!(:be_line) { create :line, line_referential: referential.line_referential, transport_mode: nil }

    let(:block){ build_stubbed :compliance_check_block, condition_attributes: condition_attributes }
    let(:condition_attributes){{}}

    before(:each) do
      fr_stop_1 = create(:stop_area, country_code: :fr)
      fr_stop_2 = create(:stop_area, country_code: :fr)
      be_stop_1 = create(:stop_area, country_code: :be)
      be_stop_2 = create(:stop_area, country_code: :be)

      route = create(:route, referential: referential, line: fr_line, stop_points_count: 0)
      route.stop_points.create(stop_area: fr_stop_1)
      route.stop_points.create(stop_area: be_stop_1)
      route.stop_points.create(stop_area: fr_stop_2)

      route = create(:route, referential: referential, line: be_line, stop_points_count: 0)
      route.stop_points.create(stop_area: be_stop_1)
      route.stop_points.create(stop_area: fr_stop_1)
      route.stop_points.create(stop_area: be_stop_2)
    end

    context 'for a transport_mode block' do
      let(:condition_attributes){
        {
          block_kind: :transport_mode,
          transport_mode: :bus,
          transport_submode: nil
        }
      }

      it 'should filter lines out' do
        expect(block.lines_scope(compliance_check_set).count).to eq 2
        expect(block.lines_scope(compliance_check_set)).to include bus_line
        expect(block.lines_scope(compliance_check_set)).to include nightBus_line
      end

      context 'with a submode' do
        let(:condition_attributes){
          {
            block_kind: :transport_mode,
            transport_mode: :bus,
            transport_submode: :nightBus
          }
        }
        it 'should filter lines out' do
          expect(block.lines_scope(compliance_check_set).count).to eq 1
          expect(block.lines_scope(compliance_check_set)).to include nightBus_line
        end
      end
    end

    context 'for a stop_areas_in_countries block' do
      let(:min_stop_areas_in_country) { "1" }
      let(:condition_attributes){
        {
          block_kind: :stop_areas_in_countries,
          country: :fr,
          min_stop_areas_in_country: min_stop_areas_in_country
        }
      }

      it 'should filter lines out' do
        expect(block.lines_scope(compliance_check_set).count).to eq 2
        expect(block.lines_scope(compliance_check_set)).to include fr_line
        expect(block.lines_scope(compliance_check_set)).to include be_line
      end

      context 'with a more restrictive condition' do
        let(:min_stop_areas_in_country) { "2" }

        it 'should filter lines out' do
          expect(block.lines_scope(compliance_check_set).count).to eq 1
          expect(block.lines_scope(compliance_check_set)).to include fr_line
        end
      end

      context 'with an even more restrictive condition' do
        let(:min_stop_areas_in_country) { "3" }

        it 'should filter lines out' do
          expect(block.lines_scope(compliance_check_set).count).to eq 0
        end
      end
    end
  end
end
