require 'rails_helper'

RSpec.describe UserObserver, type: :observer do

  context "when UserObserver is disabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( false )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_falsy
    end

    it "should not send any mail if disabled on create" do
      expect(MailerJob).to_not receive(:perform_later).with 'UserMailer', 'created', anything
      build(:user).save
    end
  end

  context "when UserObserver is enabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( true )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_truthy
    end
    context 'after_create' do
      it 'should observe user creation' do
        expect(UserObserver.instance).to receive(:after_create)
        build(:user).save
      end

      it 'should schedule mailer on user creation' do
        expect(MailerJob).to receive(:perform_later).with 'UserMailer', 'created', anything
        build(:user).save
      end
    end
  end
end
