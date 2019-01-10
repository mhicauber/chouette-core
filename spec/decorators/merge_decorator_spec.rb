# coding: utf-8
RSpec.describe MergeDecorator, type: [:helper, :decorator] do
  include Support::DecoratorHelpers

  let( :workbench ){ create :workbench }
  let( :object ){ build_stubbed :merge, workbench: workbench, new: referential }
  let( :referential ){ create :workbench_referential, workbench: workbench }
  let( :user ){ build_stubbed :user }
  let( :current_merge) { true }
  let(:context){
    { workbench: workbench }
  }

  before(:each) do
    allow(object).to receive(:current?){ current_merge }
    allow(object).to receive(:new_id){ referential.id }
  end

  describe '#aggregated_at' do
    before(:each) do
      allow(object).to receive(:successful?){ true }
    end

    context 'with no Aggregate' do
      it 'should be nil' do
        expect(subject.aggregated_at).to be_nil
      end
    end

    context 'with a failed Aggregate' do
      before do
        create :aggregate, workgroup: workbench.workgroup, status: :failed, referential_ids: [referential.id]
      end
      it 'should be nil' do
        expect(subject.aggregated_at).to be_nil
      end
    end

    context 'with a successful Aggregate on other referentials' do
      before do
        create :aggregate, ended_at: '2020/01/01 12:00', workgroup: workbench.workgroup, status: :successful, referential_ids: [create(:referential).id]
      end
      it 'should be nil' do
        expect(subject.aggregated_at).to be_nil
      end
    end

    context 'with a successful Aggregate on right referentials' do
      let!(:aggregate) do
        create :aggregate, ended_at: '2020/01/01 12:00', workgroup: workbench.workgroup, status: :successful, referential_ids: [referential.id]
      end
      it 'should be present' do
        expect(subject.aggregated_at).to eq aggregate.ended_at
      end
    end

    context 'with 2 successfuls Aggregates on right referentials' do
      let!(:aggregate) do
        create :aggregate, ended_at: '2020/01/01 12:00', workgroup: workbench.workgroup, status: :successful, referential_ids: [referential.id]
      end
      let!(:aggregate2) do
        create :aggregate, ended_at: '2020/01/01 13:00', workgroup: workbench.workgroup, status: :successful, referential_ids: [referential.id]
      end
      it 'should be present' do
        expect(subject.aggregated_at).to eq aggregate2.ended_at
      end
    end
  end

  describe 'action links for' do
    context "on show" do
      let( :action){ :show }
      it 'has corresponding actions' do
        expect_action_link_elements(action).to eq []
        expect_action_link_hrefs(action).to eq([])
      end

      context 'with a successful merge' do
        before(:each){
          object.status = :successful
          object.new = create(:referential)
        }

        it 'has corresponding actions' do
          expect_action_link_elements(action).to eq [t('merges.actions.see_associated_offer')]
          expect_action_link_hrefs(action).to eq([referential_path(object.new)])
        end

        context 'with a non-current merge' do
          let( :current_merge) { false }

          it 'has corresponding actions' do
            expect_action_link_elements(action).to eq [t('merges.actions.see_associated_offer')]
            expect_action_link_hrefs(action).to eq([referential_path(object.new)])
          end

          context "in the right organisation" do
            before(:each) do
              object.workbench.organisation = user.organisation
            end

            it 'has corresponding actions' do
              expect_action_link_elements(action).to eq [t('merges.actions.see_associated_offer')]
              expect_action_link_hrefs(action).to eq([referential_path(object.new)])
            end

            context 'with the rollback permission' do
              before(:each) do
                user.permissions = %w(merges.rollback)
              end

              it 'has corresponding actions' do
                expect_action_link_elements(action).to eq ['Revenir à cette offre', t('merges.actions.see_associated_offer')]
                expect_action_link_hrefs(action).to eq([rollback_workbench_merge_path(workbench, object), referential_path(object.new)])
              end
            end
          end
        end
      end
    end
  end
end
