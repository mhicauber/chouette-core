require 'rails_helper'

RSpec.describe Publication, type: :model do
  it { should belong_to :publication_setup }
  it { should belong_to :parent }
  it { should validate_presence_of :publication_setup }
  it { should validate_presence_of :parent }

  let(:publication_setup) { create :publication_setup, export_type: "Export::Gtfs", export_options: { duration: 90 } }
  let(:publication) { create :publication, parent: operation, publication_setup: publication_setup }
  let(:referential) { create :referential }
  let(:operation) { create :aggregate }

  before(:each) do
    allow(operation).to receive(:new){ referential }
    publication_setup.destinations.create! type: 'Destination::Dummy', name: 'I will fail', result: :expected_failure
    publication_setup.destinations.create! type: 'Destination::Dummy', name: 'I will fail unexpectedly', result: :unexpected_failure
    publication_setup.destinations.create! type: 'Destination::Dummy', name: 'I will succeed', result: :successful
  end

  describe '#publish' do
    it 'should create a PublicationWorker' do
      expect(PublicationWorker).to receive(:perform_async_or_fail)
      expect(publication).to be_pending
    end

    context 'with a failed operation' do
      before do
        operation.status = 'failed'
      end

      it 'should fail' do
        expect(publication).to be_failed
      end
    end
  end

  describe '#run' do
    it 'should call run_export' do
      expect(publication).to receive(:run_export)
      publication.run
      expect(publication).to be_running
    end
  end

  describe '#run_export' do
    before do
      allow_any_instance_of(Export::Gtfs).to receive(:save!).and_wrap_original do |m, *args|
        m.call(*args)
        m.receiver.run_callbacks(:commit)
      end
    end

    it 'should create an export' do
      expect{ publication.run_export }.to change{ Export::Gtfs.count }.by 1
      expect(GTFSExportWorker).to_not receive(:perform_async_or_fail)
      expect_any_instance_of(Export::Gtfs).to receive(:run)
      publication.run_export
      expect(publication.export).to be_present
    end

    context 'when the export succeeds' do
      before(:each) do
        allow_any_instance_of(Export::Gtfs).to receive(:export) do |obj|
          obj.update status: :successful
        end
      end

      it 'should call send_to_destinations' do
        expect(publication).to receive(:send_to_destinations)
        publication.run_export
      end

      it 'should call infer_status' do
        expect(publication).to receive(:infer_status)
        publication.run_export
      end
    end

    context 'when the export raises an error' do
      before(:each) do
        allow_any_instance_of(Export::Gtfs).to receive(:export) do |obj|
          raise "ooops"
        end
      end

      it 'should fail' do
        expect(publication).to_not receive(:send_to_destinations)
        publication.run_export
        expect(publication).to be_failed
        expect(publication.export).to be_present
        expect(publication.export).to be_persisted
      end
    end

    context 'when the export fails' do
      before(:each) do
        allow_any_instance_of(Export::Gtfs).to receive(:export) do |obj|
          obj.update status: :failed
        end
      end

      it 'should fail' do
        expect(publication).to_not receive(:send_to_destinations)
        publication.run_export
        expect(publication).to be_failed
        expect(publication.export).to be_present
      end
    end
  end
  describe '#send_to_destinations' do
    it 'should call each destination' do
      publication_setup.destinations.each do |destination|
        expect(destination).to receive(:transmit).with(publication)
      end

      expect{ publication.send_to_destinations }.to change{ Destination.where(publication_id: publication.id).count }.by publication_setup.destinations.count
    end
  end
  describe '#infer_status' do
    before(:each) do
      publication.send_to_destinations
    end

    context 'with a failed destination_report' do
      it 'should set status to successful_with_warnings' do
        expect{ publication.infer_status }.to change{ publication.status }.to 'successful_with_warnings'
      end
    end

    context 'with only successful destination_reports' do
      before(:each) do
        allow_any_instance_of(DestinationReport).to receive(:status){ 'successful' }
      end

      it 'should set status to successful' do
        expect{ publication.infer_status }.to change{ publication.status }.to 'successful'
      end
    end
  end
end
