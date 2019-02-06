RSpec.describe Chouette::SecureAction do

  context 'in a simple case' do
    let(:action) { Chouette::SecureAction.new("test action") { @done = true; 42 } }

    it 'should run the action' do
      expect{ action.duration }.to raise_error Chouette::SecureAction::ActionNotCalled
      expect(action.call).to eq 42
      expect(@done).to be_truthy
      expect(action.duration).to be > 0
    end

    context 'with a success callback' do
      it 'should run the callback' do
        action.on_success { @on_success = true }
        action.on_failure { @on_failure = true }
        action.ensure { @ensure = true }
        action.verbose = true
        expect(action).to receive(:log_info)
        expect{ action.call }.to_not raise_error
        expect(@on_success).to be_truthy
        expect(@on_failure).to be_falsy
        expect(@ensure).to be_truthy
      end
    end

  end

  context 'when it fails' do
    let(:action) { Chouette::SecureAction.new("test action") { raise } }

    it 'should run the action' do
      expect(Chouette::ErrorsManager).to receive :log
      expect{ action.call }.to_not raise_error
    end

    context 'with a failure callback' do
      it 'should run the callback' do
        action.on_success { @on_success = true }
        action.on_failure { @on_failure = true }
        action.ensure { @ensure = true }
        expect(Chouette::ErrorsManager).to receive :log
        expect{ action.call }.to_not raise_error
        expect(@on_success).to be_falsy
        expect(@on_failure).to be_truthy
        expect(action.duration).to be > 0
        expect(@ensure).to be_truthy
      end
    end
  end

  context 'using the Chouette::ErrorsManager' do
    it 'should forbid the use of protected param names' do
      expect do
        Chouette::ErrorsManager.watch 'test action' do |__run, on_failure|
        end
      end.to raise_error RuntimeError

      expect do
        Chouette::ErrorsManager.watch 'test action' do |run, __on_failure|
        end
      end.to raise_error RuntimeError
    end

    context 'with the simple form' do
      context 'when it succeeds' do
        it 'should succeed' do
          Chouette::ErrorsManager.watch 'test action' do
            @done = true
          end

          expect(@done).to be_truthy
        end
      end

      context 'when it fails' do
        it 'should fail' do
          expect(Chouette::ErrorsManager).to receive(:log)

          Chouette::ErrorsManager.watch 'test action' do
            raise 'oops'
            @done = true
          end

          expect(@done).to be_falsy
        end
      end
    end

    context 'with a single param' do
      context 'when it succeeds' do
        it 'should succeed' do
          Chouette::ErrorsManager.watch 'test action' do |blublub|
            blublub do
              @done = true
            end
          end

          expect(@done).to be_truthy
        end
      end
    end

    context 'when it succeeds' do
      it 'should not call the failure callback' do
        Chouette::ErrorsManager.watch 'test action' do |action, on_failure|
          action do
            @done = true
          end

          on_failure do
            @failure = true
          end
        end

        expect(@done).to be_truthy
        expect(@failure).to be_falsy
      end
    end

    context 'when it fails' do
      it 'should call the failure callback' do
        expect(Chouette::ErrorsManager).to receive(:log)
        Chouette::ErrorsManager.watch 'test action' do |action, on_failure|
          action do
            raise 'oops'
            @done = true
          end

          on_failure do
            @failure = true
          end
        end

        expect(@done).to be_falsy
        expect(@failure).to be_truthy
      end

      context 'when asked to raise the error' do
        it 'should raise' do
          expect(Chouette::ErrorsManager).to receive(:log)
          expect do
            Chouette::ErrorsManager.watch 'test action', raise_error: true do |action, failure|
              action do
                raise 'oops'
                @done = true
              end

              failure do
                @failure = true
              end
            end
          end.to raise_error RuntimeError
        end
      end
    end
  end
end
