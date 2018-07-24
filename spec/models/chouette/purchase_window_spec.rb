RSpec.describe Chouette::PurchaseWindow, :type => :model do
  let(:referential) {create(:referential)}
  subject  { create(:purchase_window) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:date_ranges) }

  describe 'validations' do
    it 'validates and date_ranges do not overlap' do
      expect(build(:purchase_window, date_ranges: [Date.today..Date.today + 10.day, Date.yesterday..Date.tomorrow])).to_not be_valid
      expect(build(:purchase_window, date_ranges: [Date.today..Date.today])).to be_valid
    end
  end

  describe "#overlap_dates" do
    [
      (Time.now.to_date..1.month.from_now.to_date),
      (Time.now.to_date...1.month.from_now.to_date+1.day)
    ].each do |date_range|
      subject{ Chouette::PurchaseWindow.overlap_dates(date_range) }

      let(:other_date_range){ (1.year.from_now.to_date..2.year.from_now.to_date) }

      let!(:window_1){ create :purchase_window, date_ranges: [date_range, other_date_range] }
      let!(:window_2){ create :purchase_window, date_ranges: [other_date_range] }
      let!(:window_3){ create :purchase_window, date_ranges: [(1.month.from_now.to_date..1.month.from_now.to_date), other_date_range] }
      let!(:window_4){ create :purchase_window, date_ranges: [(1.month.from_now.to_date+1.day..1.month.from_now.to_date+1.day), other_date_range] }
      let!(:window_5){ create :purchase_window, date_ranges: [(1.month.from_now.to_date+2.day..1.month.from_now.to_date+2.day), other_date_range] }

      it { should include window_1 }
      it { should_not include window_2 }
      it { should include window_3 }
      it { should_not include window_4 }
      it { should_not include window_5 }
    end
  end

  describe "#matching_dates" do
    [
      (Time.now.to_date..1.month.from_now.to_date),
      (Time.now.to_date...1.month.from_now.to_date+1.day)
    ].each do |date_range|
      subject{ Chouette::PurchaseWindow.matching_dates(date_range) }

      let!(:window_1){ create :purchase_window, date_ranges: [(Time.now.to_date..1.month.from_now.to_date)] }
      let!(:window_2){ create :purchase_window, date_ranges: [(Time.now.to_date...1.month.from_now.to_date+1.day)] }
      let!(:window_3){ create :purchase_window, date_ranges: [(Time.now.to_date...1.month.from_now.to_date)] }

      it { should include window_1 }
      it { should include window_2 }
      it { should_not include window_3 }
    end
  end

  describe 'before_validation' do
      let(:purchase_window) { build(:purchase_window, date_ranges: []) }

    it 'shoud fill date_ranges with date ranges' do
      expected_range = Date.today..Date.tomorrow
      purchase_window.date_ranges << expected_range
      purchase_window.valid?

      expect(purchase_window.date_ranges.map { |period| period.begin..period.end }).to eq([expected_range])
    end
  end

end
