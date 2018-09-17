require 'rails_helper'

RSpec.describe ImportObserver, type: :observer do
  let(:user) { create :user }
  let(:parent) { create(:workbench_import, creator: user.name) }
  let(:referential) { create :referential }
 
  context "when ImportObserver is disabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_import_observer)
        .and_return( false )

      expect(Rails.configuration.enable_import_observer).to be_falsy
    end

    it 'should not schedule mailer' do
      expect(MailerJob).to_not receive(:perform_later).with 'ImportMailer', 'finished', anything
      create(:gtfs_import, referential: referential, parent: parent).save
    end  

  end

  context 'after_update' do
    before(:each) { allow(Rails.configuration).to receive(:enable_user_observer).and_return( false ) }
    it 'should observe import finish' do
      expect(ImportObserver.instance).to receive(:after_update)
      create(:gtfs_import, referential: referential, parent: parent).save
    end

    it 'should schedule mailer on import create' do
      expect(MailerJob).to receive(:perform_later).with 'ImportMailer', 'finished', anything
      create(:gtfs_import, referential: referential, parent: parent).save
    end
  end
end
