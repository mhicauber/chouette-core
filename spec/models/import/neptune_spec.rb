require "rails_helper"

RSpec.describe Import::Neptune do

  let(:workbench) do
    create :workbench do |workbench|
      workbench.line_referential.update objectid_format: "netex"
      workbench.stop_area_referential.update objectid_format: "netex"
    end
  end

  let(:workbench_import){ create :workbench_import }

  def create_import(file=nil)
    i = build_import(file)
    i.save!
    i
  end

  def build_import(file=nil)
    file ||= 'sample_neptune'
    Import::Neptune.new workbench: workbench, local_file: fixtures_path("#{file}.zip"), creator: "test", name: "test", parent: workbench_import
  end

  before(:each) do
    allow(import).to receive(:save_model).and_wrap_original { |m, *args| m.call(*args); args.first.run_callbacks(:commit) }
  end

  context "when the file is not directly accessible" do
    let(:import) { create_import }

    before(:each) do
      allow(import).to receive(:file).and_return(nil)
    end

    it "should still be able to update the import" do
      import.update status: :failed
      expect(import.reload.status).to eq "failed"
    end
  end

  describe "created referential" do
    let(:import) { build_import }

    before(:each) do
      create :line, line_referential: workbench.line_referential
      import.send(:import_lines)
    end

    it "is named after the import name" do
      import.name = "Import Name"
      import.create_referential
      expect(import.referential.name).to eq(import.name)
    end

    it 'uses the imported lines in the metadata' do
      new_lines = workbench.line_referential.lines.last(2)
      import.create_referential
      expect(import.referential.metadatas.count).to eq 1
      expect(import.referential.metadatas.last.line_ids).to eq new_lines.map(&:id)
    end
  end

  describe "#import_lines" do
    let(:import) { build_import }

    it 'should create new lines' do
      expect{ import.send(:import_lines) }.to change{ workbench.line_referential.lines.count }.by 2
    end

    it 'should update existing lines' do
      import.send(:import_lines)
      line = workbench.line_referential.lines.last
      attrs = line.attributes.except('updated_at')
      line.update transport_mode: :tram, published_name: "foo"
      expect{ import.send(:import_lines) }.to_not change{ workbench.line_referential.lines.count }
      expect(line.reload.attributes.except('updated_at')).to eq attrs
    end
  end

  describe "#import_companies" do
    let(:import) { build_import }

    it 'should create new companies' do
      expect{ import.send(:import_companies) }.to change{ workbench.line_referential.companies.count }.by 1
    end

    it 'should update existing lines' do
      import.send(:import_companies)
      company = workbench.line_referential.companies.last
      attrs = company.attributes.except('updated_at')
      company.update name: "foo"
      expect{ import.send(:import_companies) }.to_not change{ workbench.line_referential.companies.count }
      expect(company.reload.attributes.except('updated_at')).to eq attrs
    end
  end

  describe "#import_time_tables" do
    let(:import) { create_import('sample_neptune_large') }

    before(:each) do
      import.prepare_referential
    end

    it 'should create new time_tables' do
      expect{ import.send(:import_time_tables) }.to change{ Chouette::TimeTable.count }.by 25
    end

    it 'should update existing time_tables' do
      import.send(:import_time_tables)
      expect{ import.send(:import_time_tables) }.to change{ Chouette::TimeTable.count }.by 0
    end
  end

  describe '#add_time_table_dates' do
    let(:import) { build_import }
    let(:timetable) { create(:time_table) }

    it 'should add the new dates' do
      expect{ import.send(:add_time_table_dates, timetable, '2018-10-22') }.to change{ timetable.dates.count }.by 1
      date = timetable.dates.last
      expect(date.in_out).to be_truthy
      expect(date.date).to eq '2018-10-22'.to_date
      expect{ import.send(:add_time_table_dates, timetable, '2018-10-22') }.to change{ timetable.dates.count }.by 0
      expect{ import.send(:add_time_table_dates, timetable, '2018-10-23') }.to change{ timetable.dates.count }.by 1
    end
  end

  describe '#add_time_table_periods' do
    let(:import) { build_import }
    let(:timetable) { create(:time_table) }

    it 'should add the new periods' do
      expect{
        import.send(:add_time_table_periods, timetable, { start_of_period: '2018-11-23', end_of_period: '2018-11-25'})
      }.to change{ timetable.periods.count }.by 1
    end

    it 'should merge periods' do
      expect{
        import.send(:add_time_table_periods, timetable, [
          { start_of_period: '2018-11-23', end_of_period: '2018-11-25'},
          { start_of_period: '2018-11-24', end_of_period: '2018-11-26'},
        ])
      }.to change{ timetable.periods.count }.by 1
    end

    it 'should split separate periods' do
      expect{
        import.send(:add_time_table_periods, timetable, [
          { start_of_period: '2018-11-23', end_of_period: '2018-11-25'},
          { start_of_period: '2018-11-27', end_of_period: '2018-11-29'},
        ])
      }.to change{ timetable.periods.count }.by 2
    end
  end

  describe "#int_day_types_mapping" do
    let(:import) { build_import }

    it 'should return the correct values' do
      expect(import.send(:int_day_types_mapping, 'Monday')).to eq import.send(:int_day_types_mapping, ['Monday'])
      expect(import.send(:int_day_types_mapping, 'Monday')).to eq Chouette::TimeTable::MONDAY
      expect(import.send(:int_day_types_mapping, 'Tuesday')).to eq Chouette::TimeTable::TUESDAY
      expect(import.send(:int_day_types_mapping, 'Wednesday')).to eq Chouette::TimeTable::WEDNESDAY
      expect(import.send(:int_day_types_mapping, 'Thursday')).to eq Chouette::TimeTable::THURSDAY
      expect(import.send(:int_day_types_mapping, 'Friday')).to eq Chouette::TimeTable::FRIDAY
      expect(import.send(:int_day_types_mapping, 'Saturday')).to eq Chouette::TimeTable::SATURDAY
      expect(import.send(:int_day_types_mapping, 'Sunday')).to eq Chouette::TimeTable::SUNDAY
      weekday = Chouette::TimeTable::MONDAY | Chouette::TimeTable::TUESDAY | Chouette::TimeTable::WEDNESDAY
      weekday |= Chouette::TimeTable::THURSDAY  | Chouette::TimeTable::FRIDAY
      expect(import.send(:int_day_types_mapping, 'WeekDay')).to eq weekday
      weekend = Chouette::TimeTable::SATURDAY | Chouette::TimeTable::SUNDAY
      expect(import.send(:int_day_types_mapping, 'WeekEnd')).to eq weekend

      expect(import.send(:int_day_types_mapping, %w[Friday Saturday])).to eq Chouette::TimeTable::FRIDAY | Chouette::TimeTable::SATURDAY
      expect(import.send(:int_day_types_mapping, %w[WeekEnd Saturday])).to eq weekend
    end
  end
end
