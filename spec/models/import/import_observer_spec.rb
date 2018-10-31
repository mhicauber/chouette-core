require 'rails_helper'

RSpec.describe ImportObserver, type: :observer do
  let(:user) { create :user, confirmed_at: Time.now }
  let(:workbench_import) { create(:workbench_import, creator: user.name) }
  let(:referential) { create :referential }

  it 'should observe import finish' do
    expect(ImportObserver.instance).to receive(:after_commit)
    workbench_import.status = 'successful'
    workbench_import.save
    workbench_import.run_callbacks(:commit)
  end

  it 'should schedule mailer on import finished' do
    expect(MailerJob).to receive(:perform_later).with 'ImportMailer', 'finished', anything
    workbench_import.status = 'successful'
    workbench_import.save
    workbench_import.run_callbacks(:commit)
  end
end
