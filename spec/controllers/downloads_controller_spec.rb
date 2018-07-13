require 'rails_helper'

RSpec.describe DownloadsController, type: :controller do
  let(:params){{
      path: %w(foo bar),
      extension: "csv"
  }}
  let(:request){ get :download, params }

  context "with an missing file" do
    it "should respond with a 403 error" do
      request
      expect(response.status).to eq 403
    end
  end

  context "with an existing file" do
    before(:each) do
      file = open_fixture("vehicle_journey_imports_valid.csv")
      allow(File).to receive(:open).with("#{Rails.root}/uploads/foo/bar.csv").and_return file
    end
    it "should respond with a 403 error" do
      request
      expect(response.status).to eq 403
    end
  end

  context "logged in" do
    login_user

    context "with an missing file" do
      it "should respond with a 404 error" do
        request
        expect(response.status).to eq 404
      end
    end

    context "with an existing file" do
      before(:each) do
        file = open_fixture("vehicle_journey_imports_valid.csv")
        allow(File).to receive(:open).with("#{Rails.root}/uploads/foo/bar.csv").and_return file
      end
      it "should respond with a 200 success" do
        request
        expect(response.status).to eq 200
      end
    end
  end

end
