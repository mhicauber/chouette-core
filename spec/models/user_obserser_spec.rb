require 'rails_helper'

RSpec.describe UserObserver, type: :observer do
  let(:organisation) {create :organisation, features: ['new_user_mail']}

  context "when ImportObserver is disabled" do
    before(:each) do
      allow(Rails.configuration).to receive(:enable_user_observer).and_return( false )

      expect(Rails.configuration.enable_user_observer).to be_falsy
    end

    it 'should not schedule mailer' do
      expect(MailerJob).to_not receive(:perform_later).with 'UserMailer', 'created', anything
      create(:user, organisation: organisation).save
    end
  end

  context "organisation doent have user_new_mail feature" do
    before(:each) do
      allow(organisation).to receive(:features).and_return( [] )
    end

    it 'should not schedule mailer' do
      expect(MailerJob).to_not receive(:perform_later).with 'UserMailer', 'created', anything
      create(:user, organisation: organisation).save
    end  

  end

  context 'after_create' do
    it 'should observe import create' do
      expect(UserObserver.instance).to receive(:after_create)
      create(:user, organisation: organisation).save
    end

    it 'should schedule mailer on import create' do
      expect(MailerJob).to receive(:perform_later).with 'UserMailer', 'created', anything
      create(:user, organisation: organisation).save
    end
  end
end
