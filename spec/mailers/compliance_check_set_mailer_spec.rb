require "rails_helper"

RSpec.describe MergeMailer, type: :mailer do
  let(:user) {create :user}

  let(:ccset) { create :compliance_check_set, metadata: {creator_id: user.id} }
  let(:email)    { ComplianceCheckSetMailer.send('finished', ccset.id, user.id) }

  it 'should deliver email to user' do
    expect(email).to deliver_to user.email
  end

  it 'should have correct from' do
    expect(email.from).to eq(['chouette@example.com'])
  end

  it 'should have subject' do
    expect(email).to have_subject I18n.t("mailers.compliance_check_set_mailer.finished.subject")
  end

  it 'should have correct body' do
    expect(email.body).to have_content I18n.t("mailers.compliance_check_set_mailer.finished.body", ref_name: ccset.referential.name, status: I18n.t("operation_support.statuses.#{ccset.status}"))
  end
end
