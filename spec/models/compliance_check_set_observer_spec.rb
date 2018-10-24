require 'rails_helper'

RSpec.describe ComplianceCheckSetObserver, type: :observer do
  let(:user) { create :user, confirmed_at: Time.now }
  let(:check_set){create :compliance_check_set, parent: create(:netex_import), referential: create(:referential)}
 
  context "when notifications are disabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( false )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_falsy
    end

    it 'should not schedule mailer' do
      check_set.status = 'successful'
      check_set.save
      expect(MailerJob).to_not receive(:perform_later).with 'ComplianceCheckSetMailer', 'finished', anything
    end  

  end

  context 'when notifications are enabled' do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( true )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_truthy
    end
    it 'should observe ccset finish' do
      expect(ComplianceCheckSetObserver.instance).to receive(:after_update)
      check_set.status = 'successful'
      check_set.save
    end

    it 'should schedule mailer on ccset finish' do
      expect(MailerJob).to receive(:perform_later).with 'ComplianceCheckSetMailer', 'finished', anything
      check_set.status = 'successful'
      check_set.save
    end
  end
end
