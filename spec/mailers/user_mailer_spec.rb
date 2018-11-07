require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  let(:user)    { create(:user) }
  let(:support_team_mails) { ['support@enroute.paris', 'chouette-marcom@af83.com'] }
  let(:email)    { UserMailer.send('created', user.id, support_team_mails) }

  it 'should deliver email to user' do
    expect(email).to deliver_to(support_team_mails)
  end

  it 'should have correct from' do
    expect(email.from).to eq(['chouette@example.com'])
  end

  it 'should have subject' do
    expect(email).to have_subject I18n.t("mailers.user_mailer.created.subject")
  end

  it 'should have correct body' do
    expect(email.body.raw_source.gsub("\r\n", "\n")).to include I18n.t("mailers.user_mailer.created.body", user_name: user.name, orga_name: user.organisation.name, user_mail: user.email)
  end
end
