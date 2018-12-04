RSpec.describe Chouette::Route, :type => :model do
  subject { create(:route) }

  describe 'checksum' do
    it_behaves_like 'checksum support'
  end

  it { is_expected.to enumerize(:direction).in(:straight_forward, :backward, :clockwise, :counter_clockwise, :north, :north_west, :west, :south_west, :south, :south_east, :east, :north_east) }
  it { is_expected.to enumerize(:wayback).in(:outbound, :inbound) }
  #it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :line }
  it { is_expected.to validate_uniqueness_of :objectid }
  #it { is_expected.to validate_presence_of :wayback_code }
  #it { is_expected.to validate_presence_of :direction_code }
  it { is_expected.to validate_inclusion_of(:direction).in_array(%i(straight_forward backward clockwise counter_clockwise north north_west west south_west south south_east east north_east)) }
  it { is_expected.to validate_inclusion_of(:wayback).in_array(%i(outbound inbound)) }
  
  it "should have at least 2 stop points" do
    route1 = build(:route, stop_points: create_list(:stop_point, 2) )
    expect(route1).to be_valid
    
    
    route2 = build(:route, stop_points: create_list(:stop_point, 1) )
    expect(route2).not_to be_valid
    expect(route2.errors.messages[:stop_points]).to be
    expect(route2.errors.messages[:stop_points]).to include( I18n.t('activerecord.errors.models.route.attributes.stop_points.not_enough_stop_points') )
  end

  context "reordering methods" do
    let(:bad_stop_point_ids){subject.stop_points.map { |sp| sp.id + 1}}
    let(:ident){subject.stop_points.map(&:id)}
    let(:first_last_swap){ [ident.last] + ident[1..-2] + [ident.first]}

    describe "#reorder!" do
      context "invalid stop_point_ids" do
        let(:new_stop_point_ids) { bad_stop_point_ids}
        it { expect(subject.reorder!( new_stop_point_ids)).to be_falsey}
      end

      context "swaped last and first stop_point_ids" do
        let!(:new_stop_point_ids) { first_last_swap}
        let!(:old_stop_point_ids) { subject.stop_points.map(&:id) }
        let!(:old_stop_area_ids) { subject.stop_areas.map(&:id) }

        it "should keep stop_point_ids order unchanged" do
          expect(subject.reorder!( new_stop_point_ids)).to be_truthy
          expect(subject.stop_points.map(&:id)).to eq( old_stop_point_ids)
        end
        # This test is no longer relevant, as reordering is done with Reactux
        # it "should have changed stop_area_ids order" do
        #   expect(subject.reorder!( new_stop_point_ids)).to be_truthy
        #   subject.reload
        #   expect(subject.stop_areas.map(&:id)).to eq( [old_stop_area_ids.last] + old_stop_area_ids[1..-2] + [old_stop_area_ids.first])
        # end
      end
    end

    describe "#stop_point_permutation?" do
      context "invalid stop_point_ids" do
        let( :new_stop_point_ids ) { bad_stop_point_ids}
        it { is_expected.not_to be_stop_point_permutation( new_stop_point_ids)}
      end
      context "unchanged stop_point_ids" do
        let(:new_stop_point_ids) { ident}
        it { is_expected.to be_stop_point_permutation( new_stop_point_ids)}
      end
      context "swaped last and first stop_point_ids" do
        let(:new_stop_point_ids) { first_last_swap}
        it { is_expected.to be_stop_point_permutation( new_stop_point_ids)}
      end
    end
  end

  context "callbacks" do
    it "calls #calculate_costs! after_commit when TomTom is enabled", truncation: true do
      allow(TomTom).to receive(:enabled?).and_return(true)
      route = build(:route)

      expect(route).to receive(:calculate_costs!)
      route.save
    end

    it "doesn't call #calculate_costs! after_commit if TomTom is disabled", truncation: true do
      allow(TomTom).to receive(:enabled?).and_return(false)
      route = build(:route)

      expect(route).not_to receive(:calculate_costs!)
      route.save
    end

    it "doesn't call #calculate_costs! after_commit if in a ReferentialSuite",
        truncation: true do
      begin
        allow(TomTom).to receive(:enabled?).and_return(true)

        referential_suite = create(:referential_suite)
        referential = create(:referential, referential_suite: referential_suite)

        referential.switch do
          route = build(:route)

          expect(route).not_to receive(:calculate_costs!)
          route.save
        end
      ensure
        referential.destroy
      end
    end
  end
end
