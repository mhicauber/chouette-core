require 'rails_helper'

RSpec.describe ComplianceCheckSetObserver, type: :observer do
  let(:user) { create :user, confirmed_at: Time.now }
  let(:notification_target) { nil }
  subject(:check_set) do
    create :compliance_check_set,
           parent: create(:netex_import),
           referential: create(:referential),
           context: :manual,
           notification_target: notification_target,
           user: user,
           metadata: { creator_id: create(:user).id }
  end
  let(:mailer) { ComplianceCheckSetMailer }
  let(:observer) { ComplianceCheckSetObserver }

  it_behaves_like 'a notifiable operation'
end
