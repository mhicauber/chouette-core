require 'rails_helper'

RSpec.describe ExportObserver, type: :observer do
  let(:user) { create :user, confirmed_at: Time.now }
  let(:parent) { create(:workbench_import, creator: user.name) }
  let(:referential) { create :referential }
  let(:export) { create(:gtfs_export, creator: user.name) }

  it 'should observe export create' do
    expect(ExportObserver.instance).to receive(:after_commit)
    export.status = 'successful'
    export.save
    export.run_callbacks(:commit)
  end

  it 'should schedule mailer on import create' do
    expect(MailerJob).to receive(:perform_later).with('ExportMailer', 'finished', anything).exactly(:once)
    export.status = 'successful'
    export.save
    export.run_callbacks(:commit)
    export.touch
    export.save
    export.run_callbacks(:commit)
  end
end
