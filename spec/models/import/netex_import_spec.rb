RSpec.describe Import::Netex, type: [:model, :with_commit] do

  # FIXME call_iev_callback is called from create_with_referential!
  # The test process must be refactored

  # let( :boiv_iev_uri ){  URI("#{Rails.configuration.iev_url}/boiv_iev/referentials/importer/new?id=#{subject.id}")}

  # before do
  #   allow(Thread).to receive(:new).and_yield
  # end

  # context 'with referential' do
  #   subject{ build( :netex_import, id: random_int ) }

  #   it 'will trigger the Java API' do
  #     with_stubbed_request(:get, boiv_iev_uri) do |request|
  #       with_commit{ subject.save! }
  #       expect(request).to have_been_requested
  #     end
  #   end
  # end

  # context 'without referential' do
  #   subject { build :netex_import, referential_id: nil }

  #   it 'its status is forced to aborted and the Java API is not callled' do
  #     with_stubbed_request(:get, boiv_iev_uri) do |request|
  #       with_commit{ subject.save! }
  #       expect(subject.reload.status).to eq('aborted')
  #       expect(request).not_to have_been_requested
  #     end
  #   end
  # end

  describe "#notify_parent" do

    it "makes referential `ready` when status is successful or warning" do
      workbench_import = create(:workbench_import)

      %w(failed aborted canceled).each do |status|
        netex_import = create(:netex_import, parent: workbench_import)
        netex_import.update_column(:status, status)
        netex_import.notify_parent

        expect(netex_import.referential.ready).to be false
      end
    end

    it "makes referential `ready` when status is successful or warning" do
      workbench_import = create(:workbench_import)

      %w(successful warning).each do |status|
        netex_import = create(:netex_import, parent: workbench_import)
        netex_import.update_column(:status, status)
        netex_import.notify_parent

        expect(netex_import.referential.ready).to be true
      end
    end

  end

  describe "#destroy" do
    it "must destroy its associated Referential if ready: false" do
      workbench_import = create(:workbench_import)
      referential_ready_false = create(:referential, status: :pending)
      referential_ready_true = create(:referential, ready: true)
      create(
        :netex_import,
        parent: workbench_import,
        referential: referential_ready_false
      )
      create(
        :netex_import,
        parent: workbench_import,
        referential: referential_ready_true
      )

      workbench_import.destroy

      expect(
        Referential.where(id: referential_ready_false.id).exists?
      ).to be false
      expect(
        Referential.where(id: referential_ready_true.id).exists?
      ).to be true
    end

    it "doesn't try to destroy nil referentials" do
      workbench_import = create(:workbench_import)
      create(
        :netex_import,
        parent: workbench_import,
        referential: nil
      )

      expect { workbench_import.destroy }.not_to raise_error
    end
  end

end
