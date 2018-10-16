RSpec.describe AF83::ChecksumManager::Transactional do
  context "#commit" do
    it "should raise an exception" do
      expect do
        AF83::ChecksumManager.commit
      end.to raise_error(AF83::ChecksumManager::NotInTransactionError)
    end
  end

  context "in a transaction" do
    let(:route){ create(:route) }

    before(:each) do
      AF83::ChecksumManager.start_transaction unless AF83::ChecksumManager.in_transaction?

      @update_calls = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = 0 } }
      allow_any_instance_of(Chouette::Route).to receive(:update_checksum_without_callbacks!).and_wrap_original do |m, *opts|
        @update_calls[m.receiver.class][m.receiver.id] += 1
        m.call(*opts)
      end
    end

    it 'should use a transactional manager' do
      expect(AF83::ChecksumManager.current).to be_a(AF83::ChecksumManager::Transactional)
      AF83::ChecksumManager.commit
    end

    it 'should not update any checksum' do
      route
      expect(@update_calls.size).to eq(0)
      AF83::ChecksumManager.commit
    end

    it 'should raise an error if we try to write in distinct referentials' do
      create(:route)
      create(:referential).switch
      expect { create(:route) }.to raise_error AF83::ChecksumManager::MultipleReferentialsError
    end

    context "after #commit" do
      it 'should update the checksum (but only once)' do
        route
        route.update name: "route"
        stop_point = Chouette::StopPoint.find(route.stop_points.last.id)
        stop_point.destroy
        expect(@update_calls.size).to eq(0)
        AF83::ChecksumManager.commit
        expect(route.checksum).to be_present
        expect(@update_calls[Chouette::Route].size).to eq(1)
        expect(@update_calls[Chouette::Route][route.id]).to eq(1)
        expect{ route.update_checksum_without_callbacks! }.to_not change { route.checksum }
      end

      it 'should go back to an inline manager' do
        AF83::ChecksumManager.commit
        expect(AF83::ChecksumManager.current).to be_a(AF83::ChecksumManager::Inline)
      end

      context "with dependencies" do
        before(:each) do
          allow_any_instance_of(Chouette::VehicleJourney).to receive(:update_checksum_without_callbacks!).and_wrap_original do |m, *opts|
            @update_calls[m.receiver.class][m.receiver.id] += 1
            m.call(*opts)
          end
        end

        it "should resolve in the right order" do
          vj = create(:vehicle_journey)

          AF83::ChecksumManager.commit

          @update_calls = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = 0 } }

          AF83::ChecksumManager.transaction do
            vjas = vj.vehicle_journey_at_stops.first
            vjas.update arrival_time: "02:00"

            expect(@update_calls.size).to eq(0)
            expect(
              AF83::ChecksumManager.current.send(:is_dirty?, vjas)
            ).to be_truthy
            expect(
              AF83::ChecksumManager.current.send(:is_dirty?, vj.vehicle_journey_at_stops.last)
            ).to be_falsy
            vjas = Chouette::VehicleJourneyAtStop.find vj.vehicle_journey_at_stops.last.id
            vjas.destroy
          end

          expect(@update_calls[Chouette::VehicleJourney].size).to eq(1)

          vj.vehicle_journey_at_stops.each do |vjas|
            expect{ vjas.reload }.to_not change { vjas.checksum_source }
            expect{ vjas.update_checksum_without_callbacks! }.to_not change { vjas.checksum_source }
          end
          expect{ vj.reload }.to_not change { vj.reload.checksum_source }
          expect{ vj.update_checksum_without_callbacks! }.to_not change { vj.checksum_source }
          expect{ vj.journey_pattern.reload }.to_not change { vj.journey_pattern.reload.checksum_source }
          expect{ vj.journey_pattern.update_checksum_without_callbacks! }.to_not change { vj.journey_pattern.checksum_source }
        end
      end
    end
  end
end
