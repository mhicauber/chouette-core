require 'rails_helper'

RSpec.describe ComplianceCheckSetObserver, type: :observer do
  let(:user) { create :user, confirmed_at: Time.now }
  let(:check_set) do
    create :compliance_check_set,
           parent: create(:netex_import),
           referential: create(:referential),
           context: :manual,
           metadata: { creator_id: create(:user).id }
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
