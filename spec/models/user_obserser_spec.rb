require 'rails_helper'

RSpec.describe UserObserver, type: :observer do
  let(:organisation) {create :organisation}

  context "when notifications are disabled" do
    before(:each) do
      allow(Rails.configuration).to receive(:enable_subscriptions_notifications).and_return( false )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_falsy
    end

    it 'should not schedule mailer' do
      expect(MailerJob).to_not receive(:perform_later).with 'UserMailer', 'created', anything
      create(:user, organisation: organisation).save
    end
  end

  context 'when notification are allowed' do
    before(:each) do
      allow(Rails.configuration).to receive(:enable_subscriptions_notifications).and_return( true )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_truthy
    end

    it 'should observe user create' do
      expect(UserObserver.instance).to receive(:after_create)
      create(:user, organisation: organisation).save
    end

    it 'should schedule mailer on user create' do
      expect(MailerJob).to receive(:perform_later).with 'UserMailer', 'created', anything
      create(:user, organisation: organisation).save
    end
  end
end
