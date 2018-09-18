require 'rails_helper'

RSpec.describe MergeObserver, type: :observer do
  let(:user) { create :user }
  let(:stop_area_referential){ create :stop_area_referential }
  let(:line_referential){ create :line_referential }
  let(:company){ create :company, line_referential: line_referential }
  let(:workbench){ create :workbench, line_referential: line_referential, stop_area_referential: stop_area_referential }
  let(:referential) { create :referential, workbench: workbench, organisation: workbench.organisation }
  let(:referential_metadata){ create(:referential_metadata, lines: line_referential.lines.limit(3), referential: referential) }

  let(:merge) { Merge.create(workbench: referential.workbench, referentials: [referential, referential], creator: user.name) }
 
  context "when MergeObserver is disabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_merge_observer)
        .and_return( false )

      expect(Rails.configuration.enable_merge_observer).to be_falsy
    end

    it 'should not schedule mailer' do
      merge.status = 'successful'
      expect(MailerJob).to_not receive(:perform_later).with 'MergeMailer', 'finished', anything
      merge.save
    end  

  end

  context 'after_update' do
    before(:each) { allow(Rails.configuration).to receive(:enable_user_observer).and_return( false ) }
    it 'should observe merge finish' do
      merge.status = 'successful'
      expect(MergeObserver.instance).to receive(:after_update)
      merge.save
    end

    it 'should schedule mailer on merge finish' do
      merge.status = 'successful'
      expect(MailerJob).to receive(:perform_later).with 'MergeMailer', 'finished', anything
      merge.save
    end
  end
end
