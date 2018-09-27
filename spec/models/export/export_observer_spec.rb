require 'rails_helper'

RSpec.describe ExportObserver, type: :observer do
  let(:user) { create :user }
  let(:parent) { create(:workbench_import, creator: user.name) }
  let(:referential) { create :referential }
 
  context "when notifications are disabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( false )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_falsy
    end

    it 'should not schedule mailer' do
      expect(MailerJob).to_not receive(:perform_later).with 'ExportMailer', 'created', anything
      create(:gtfs_export, creator: user.name).save
    end  

  end

  context 'when notifications are enabled' do
     before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( true )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_truthy
     end
    
    it 'should observe export create' do
      expect(ExportObserver.instance).to receive(:after_create)
      create(:gtfs_export, creator: user.name).save
    end

    xit 'should schedule mailer on import create' do
      expect(MailerJob).to receive(:perform_later).with 'ExportMailer', 'created', anything
      create(:gtfs_export, creator: user.name).save
    end
  end
end
