require "rails_helper"

RSpec.describe Import::Gtfs do

  let(:referential) do
    create :referential do |referential|
      referential.line_referential.objectid_format = "netex"
      referential.stop_area_referential.objectid_format = "netex"
    end
  end

  let(:workbench) do
    create :workbench do |workbench|
      workbench.line_referential.objectid_format = "netex"
      workbench.stop_area_referential.objectid_format = "netex"
    end
  end

  def create_import(file)
    Import::Gtfs.new workbench: workbench, local_file: fixtures_path(file)
  end

  context "when the file is not directly accessible" do
    let(:import) {
      Import::Gtfs.create workbench: workbench, name: "test", creator: "Albator", file: open_fixture("google-sample-feed.zip")
    }

    before(:each) do
      allow(import).to receive(:file).and_return(nil)
    end

    it "should still be able to update the import" do
      import.update status: :failed
      expect(import.reload.status).to eq "failed"
    end
  end

  describe "created referential" do

    let(:import) { create_import "google-sample-feed.zip" }

    it "is named with the import name" do
      import.name = "Import Name"
      import.prepare_referential
      expect(import.referential.name).to eq(import.name)
    end

  end

  describe "#import_agencies" do
    let(:import) { create_import "google-sample-feed.zip" }
    it "should create a company for each agency" do
      import.import_agencies

      expect(workbench.line_referential.companies.pluck(:registration_number, :name, :url, :time_zone)).to eq([["DTA","Demo Transit Authority","http://google.com","America/Los_Angeles"]])
    end
  end

  describe "#import_stops" do
    let(:import) { create_import "google-sample-feed.zip" }
    it "should create a company for each agency" do
      import.import_stops

      defined_attributes = [
        :registration_number, :name, :parent_id, :latitude, :longitude
      ]
      expected_attributes = [
        ["AMV", "Amargosa Valley (Demo)", nil, 36.641496, -116.40094],
        ["EMSI", "E Main St / S Irving St (Demo)", nil, 36.905697, -116.76218],
        ["DADAN", "Doing Ave / D Ave N (Demo)", nil, 36.909489, -116.768242],
        ["NANAA", "North Ave / N A Ave (Demo)", nil, 36.914944, -116.761472],
        ["NADAV", "North Ave / D Ave N (Demo)", nil, 36.914893, -116.76821],
        ["STAGECOACH", "Stagecoach Hotel & Casino (Demo)", nil, 36.915682, -116.751677],
        ["BULLFROG", "Bullfrog (Demo)", nil, 36.88108, -116.81797],
        ["BEATTY_AIRPORT", "Nye County Airport (Demo)", nil, 36.868446, -116.784582],
        ["FUR_CREEK_RES", "Furnace Creek Resort (Demo)", nil, 36.425288, -117.133162]
      ]

      expect(workbench.stop_area_referential.stop_areas.pluck(*defined_attributes)).to match_array(expected_attributes)
    end
  end

  describe "#import_routes" do
    let(:import) { create_import "google-sample-feed.zip" }
    it "should create a line for each route" do
      import.import_routes

      defined_attributes = [
        :registration_number, :name, :number, :published_name,
        "companies.registration_number",
        :comment, :url
      ]
      expected_attributes = [
        ["AAMV", "Airport - Amargosa Valley", "50", "Airport - Amargosa Valley", nil, nil, nil],
        ["CITY", "City", "40", "City", nil, nil, nil],
        ["STBA", "Stagecoach - Airport Shuttle", "30", "Stagecoach - Airport Shuttle", nil, nil, nil],
        ["BFC", "Bullfrog - Furnace Creek Resort", "20", "Bullfrog - Furnace Creek Resort", nil, nil, nil],
        ["AB", "Airport - Bullfrog", "10", "Airport - Bullfrog", nil, nil, nil]
      ]

      expect(workbench.line_referential.lines.includes(:company).pluck(*defined_attributes)).to match_array(expected_attributes)
    end
  end

  describe "#import_trips" do
    let(:import) { create_import "google-sample-feed.zip" }
    before do
      import.prepare_referential
      import.import_calendars
    end

    it "should create a Route for each trip" do
      import.import_trips

      defined_attributes = [
        "lines.registration_number", :wayback, :name, :published_name
      ]
      expected_attributes = [
        ["AB", "outbound", "to Bullfrog", "to Bullfrog"],
        ["AB", "inbound", "to Airport", "to Airport"],
        ["STBA", "inbound", "Shuttle", "Shuttle"],
        ["CITY", "outbound", "Outbound", "Outbound"],
        ["CITY", "inbound", "Inbound", "Inbound"],
        ["BFC", "outbound", "to Furnace Creek Resort", "to Furnace Creek Resort"],
        ["BFC", "inbound", "to Bullfrog", "to Bullfrog"],
        ["AAMV", "outbound", "to Amargosa Valley", "to Amargosa Valley"],
        ["AAMV", "inbound", "to Airport", "to Airport"],
        ["AAMV", "outbound", "to Amargosa Valley", "to Amargosa Valley"],
        ["AAMV", "inbound", "to Airport", "to Airport"]
      ]

      expect(import.referential.routes.includes(:line).pluck(*defined_attributes)).to match_array(expected_attributes)
    end

    it "should create a JourneyPattern for each trip" do
      import.import_trips

      defined_attributes = [
        :name
      ]
      expected_attributes = [
        "to Bullfrog", "to Airport", "Shuttle", "Outbound", "Inbound", "to Furnace Creek Resort", "to Bullfrog", "to Amargosa Valley", "to Airport", "to Amargosa Valley", "to Airport"
      ]

      expect(import.referential.journey_patterns.pluck(*defined_attributes)).to match_array(expected_attributes)
    end

    it "should create a VehicleJourney for each trip" do
      import.import_trips

      defined_attributes = ->(v) {
        [v.published_journey_name, v.time_tables.first&.comment]
      }
      expected_attributes = [
        ["to Bullfrog", "Calendar FULLW"],
        ["to Airport", "Calendar FULLW"],
        ["Shuttle", "Calendar FULLW"],
        ["CITY1", "Calendar FULLW"],
        ["CITY2", "Calendar FULLW"],
        ["to Furnace Creek Resort", "Calendar FULLW"],
        ["to Bullfrog", "Calendar FULLW"],
        ["to Amargosa Valley", "Calendar WE"],
        ["to Airport", "Calendar WE"],
        ["to Amargosa Valley", "Calendar WE"],
        ["to Airport", "Calendar WE"]
      ]

      expect(import.referential.vehicle_journeys.map(&defined_attributes)).to match_array(expected_attributes)
    end
  end

  describe "#import_stop_times" do
    let(:import) { create_import "google-sample-feed.zip" }

    before do
      import.prepare_referential
      import.import_calendars
      import.import_trips
    end

    it "should create a VehicleJourneyAtStop for each stop_time" do
      import.import_stop_times

      def t(value)
        Time.parse(value)
      end

      defined_attributes = [
        "stop_areas.registration_number", :position, :departure_time, :arrival_time,
      ]
      expected_attributes = [
        ["STAGECOACH", 0, t("2000-01-01 06:00:00 UTC"), t("2000-01-01 06:00:00 UTC")],
        ["BEATTY_AIRPORT", 1, t("2000-01-01 06:20:00 UTC"), t("2000-01-01 06:20:00 UTC")],
        ["STAGECOACH", 0, t("2000-01-01 06:00:00 UTC"), t("2000-01-01 06:00:00 UTC")],
        ["NANAA", 1, t("2000-01-01 06:07:00 UTC"), t("2000-01-01 06:05:00 UTC")],
        ["NADAV", 2, t("2000-01-01 06:14:00 UTC"), t("2000-01-01 06:12:00 UTC")],
        ["DADAN", 3, t("2000-01-01 06:21:00 UTC"), t("2000-01-01 06:19:00 UTC")],
        ["EMSI", 4, t("2000-01-01 06:28:00 UTC"), t("2000-01-01 06:26:00 UTC")],
        ["EMSI", 0, t("2000-01-01 06:30:00 UTC"), t("2000-01-01 06:28:00 UTC")],
        ["DADAN", 1, t("2000-01-01 06:37:00 UTC"), t("2000-01-01 06:35:00 UTC")],
        ["NADAV", 2, t("2000-01-01 06:44:00 UTC"), t("2000-01-01 06:42:00 UTC")],
        ["NANAA", 3, t("2000-01-01 06:51:00 UTC"), t("2000-01-01 06:49:00 UTC")],
        ["STAGECOACH", 4, t("2000-01-01 06:58:00 UTC"), t("2000-01-01 06:56:00 UTC")],
        ["BEATTY_AIRPORT", 0, t("2000-01-01 08:00:00 UTC"), t("2000-01-01 08:00:00 UTC")],
        ["BULLFROG", 1, t("2000-01-01 08:15:00 UTC"), t("2000-01-01 08:10:00 UTC")],
        ["BULLFROG", 0, t("2000-01-01 12:05:00 UTC"), t("2000-01-01 12:05:00 UTC")],
        ["BEATTY_AIRPORT", 1, t("2000-01-01 12:15:00 UTC"), t("2000-01-01 12:15:00 UTC")],
        ["BULLFROG", 0, t("2000-01-01 08:20:00 UTC"), t("2000-01-01 08:20:00 UTC")],
        ["FUR_CREEK_RES", 1, t("2000-01-01 09:20:00 UTC"), t("2000-01-01 09:20:00 UTC")],
        ["FUR_CREEK_RES", 0, t("2000-01-01 11:00:00 UTC"), t("2000-01-01 11:00:00 UTC")],
        ["BULLFROG", 1, t("2000-01-01 12:00:00 UTC"), t("2000-01-01 12:00:00 UTC")],
        ["BEATTY_AIRPORT", 0, t("2000-01-01 08:00:00 UTC"), t("2000-01-01 08:00:00 UTC")],
        ["AMV", 1, t("2000-01-01 09:00:00 UTC"), t("2000-01-01 09:00:00 UTC")],
        ["AMV", 0, t("2000-01-01 10:00:00 UTC"), t("2000-01-01 10:00:00 UTC")],
        ["BEATTY_AIRPORT", 1, t("2000-01-01 11:00:00 UTC"), t("2000-01-01 11:00:00 UTC")],
        ["BEATTY_AIRPORT", 0, t("2000-01-01 13:00:00 UTC"), t("2000-01-01 13:00:00 UTC")],
        ["AMV", 1, t("2000-01-01 14:00:00 UTC"), t("2000-01-01 14:00:00 UTC")],
        ["AMV", 0, t("2000-01-01 15:00:00 UTC"), t("2000-01-01 15:00:00 UTC")],
        ["BEATTY_AIRPORT", 1, t("2000-01-01 16:00:00 UTC"), t("2000-01-01 16:00:00 UTC")]
      ]
      expect(referential.vehicle_journey_at_stops.includes(stop_point: :stop_area).pluck(*defined_attributes)).to match_array(expected_attributes)
    end
  end

  describe "#import_calendars" do
    let(:import) { create_import "google-sample-feed.zip" }

    before do
      import.prepare_referential
    end

    it "should create a Timetable for each calendar" do
      import.import_calendars

      def d(value)
        Date.parse(value)
      end

      defined_attributes = ->(t) {
        [t.comment, t.valid_days, t.periods.first.period_start, t.periods.first.period_end]
      }
      expected_attributes = [
        ["Calendar FULLW", [1, 2, 3, 4, 5, 6, 7], d("Mon, 01 Jan 2007"), d("Fri, 31 Dec 2010")],
        ["Calendar WE", [6, 7], d("Mon, 01 Jan 2007"), d("Fri, 31 Dec 2010")]
      ]
      expect(referential.time_tables.map(&defined_attributes)).to match_array(expected_attributes)
    end
  end

  describe "#import_calendar_dates" do
    let(:import) { create_import "google-sample-feed.zip" }

    before do
      import.prepare_referential
    end

    it "should create time_tables when they don't already exist" do
      expect{import.import_calendar_dates}.to change{Chouette::TimeTable.count}.by 1
      timetable = Chouette::TimeTable.last
      expect(timetable.comment).to eq "Calendar FULLW"
      expect(timetable.periods.count).to eq 0
      expect(timetable.dates.count).to eq 1
      expect(timetable.dates.last.date).to eq "2007-06-04".to_date
      expect(timetable.dates.last.in_out).to be_falsy

      timetable.dates.destroy_all
      expect{import.import_calendar_dates}.to change{Chouette::TimeTable.count}.by 0
    end

    context "when the timetables exist" do
      before do
        import.import_calendars
      end

      it "should create a Timetable::Date for each calendar date" do
        import.import_calendar_dates

        def d(value)
          Date.parse(value)
        end

        defined_attributes = ->(d) {
          [d.time_table.comment, d.date, d.in_out]
        }
        expected_attributes = [
          ["Calendar FULLW", d("Mon, 04 Jun 2007"), false]
        ]
        expect(referential.time_table_dates.map(&defined_attributes)).to match_array(expected_attributes)
      end
    end
  end

  describe "#download_local_file" do
    let(:file) { "google-sample-feed.zip" }
    let(:import) do
      Import::Gtfs.create! name: "GTFS test", creator: "Test", workbench: workbench, file: open_fixture(file), download_host: "rails_host"
    end

    let(:download_url) { "#{import.download_host}/workbenches/#{import.workbench_id}/imports/#{import.id}/download?token=#{import.token_download}" }

    before do
      stub_request(:get, download_url).to_return(status: 200, body: read_fixture(file))
    end

    it "should download local_file" do
      expect(File.read(import.download_local_file)).to eq(read_fixture(file))
    end
  end

  describe "#download_uri" do
    let(:import) { Import::Gtfs.new }

    before do
      allow(import).to receive(:download_path).and_return("/download_path")
    end

    context "when download_host is 'front'" do
      before { allow(import).to receive(:download_host).and_return("front") }
      it "returns http://front/download_path" do
        expect(import.download_uri.to_s).to eq('http://front/download_path')
      end
    end

    context "when download_host is 'front:3000'" do
      before { allow(import).to receive(:download_host).and_return("front:3000") }
      it "returns http://front:3000/download_path" do
        expect(import.download_uri.to_s).to eq('http://front:3000/download_path')
      end
    end

    context "when download_host is 'http://front:3000'" do
      before { allow(import).to receive(:download_host).and_return("http://front:3000") }
      it "returns http://front:3000/download_path" do
        expect(import.download_uri.to_s).to eq('http://front:3000/download_path')
      end
    end

    context "when download_host is 'https://front:3000'" do
      before { allow(import).to receive(:download_host).and_return("https://front:3000") }
      it "returns https://front:3000/download_path" do
        expect(import.download_uri.to_s).to eq('https://front:3000/download_path')
      end
    end

    context "when download_host is 'http://front'" do
      before { allow(import).to receive(:download_host).and_return("http://front") }
      it "returns http://front/download_path" do
        expect(import.download_uri.to_s).to eq('http://front/download_path')
      end
    end

  end

  describe "#download_host" do
    it "should return host defined by Rails.application.config.rails_host" do
      allow(Rails.application.config).to receive(:rails_host).and_return("download_host")
      expect(Import::Gtfs.new.download_host).to eq("download_host")
    end
  end

  describe "#download_path" do
    let(:file) { "google-sample-feed.zip" }
    let(:import) do
      Import::Gtfs.create! name: "GTFS test", creator: "Test", workbench: workbench, file: open_fixture(file), download_host: "rails_host"
    end

    it "should return the pathwith the token" do
      expect(import.download_path).to eq("/workbenches/#{import.workbench_id}/imports/#{import.id}/download?token=#{import.token_download}")
    end
  end

  describe "#referential_metadata" do
    let(:import) { create_import "google-sample-feed.zip" }
    let(:start_date_limit) { Date.current.beginning_of_year - 15.years }
    let(:end_date_limit) { Date.current.end_of_year + 15.years }

    context "when dates are over the extremes" do
      before do
        allow(import.source).to receive(:calendars).and_return([
          double(start_date: (Date.current - 20.years).to_s, end_date: (Date.current + 20.years).to_s)
        ])
      end

      it "sets periodes within the allowed limit" do
        expect(import.referential_metadata.periodes).to eq([start_date_limit..end_date_limit])
      end
    end

    context "when dates are inside the extremes" do
      before do
        allow(import.source).to receive(:calendars).and_return([
          double(start_date: 1.month.ago.to_date.to_s, end_date: 1.year.since.to_date.to_s)
        ])
      end

      it "sets periodes within the allowed limit" do
        expect(import.referential_metadata.periodes).to eq([1.month.ago.to_date..1.year.since.to_date])
      end
    end
  end
end
