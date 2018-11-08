RSpec.shared_examples_for 'a notifiable operation' do
  let(:notification_target) { nil }

  before(:each) do
    workbench = subject.workbench_for_notifications
    3.times do
      workbench.organisation.users << create(:user)
    end
  end

  it 'should observe when finished' do
    expect(observer.instance).to receive(:after_update).exactly(:once)
    subject.status = 'successful'
    subject.save
  end

  context 'without notification_target' do
    it 'should schedule mailer when finished' do
      expect(MailerJob).to_not receive(:perform_later)
      subject.status = 'successful'
      subject.save
      expect(subject.notified_recipients?).to be_falsy
    end

    it 'should not schedule mailer when not finished' do
      expect(MailerJob).to_not receive(:perform_later)
      subject.status = 'running'
      subject.save
      expect(subject.notified_recipients?).to be_falsy
    end
  end

  context 'with notification_target set to user' do
    let(:notification_target) { :user }

    it 'should schedule mailer when finished' do
      expect(MailerJob).to receive(:perform_later).with(mailer.name, 'finished', [subject.id, [user.email_recipient], 'successful']).exactly(:once)
      subject.status = 'successful'
      subject.save
      expect(subject.notified_recipients?).to be_truthy
    end
  end

  context 'with notification_target set to workbench' do
    let(:notification_target) { :workbench }

    it 'should schedule mailer when finished' do
      expect(MailerJob).to receive(:perform_later).with(mailer.name, 'finished', [subject.id, subject.workbench_for_notifications.users.map(&:email_recipient), 'successful']).exactly(:once)
      subject.status = 'successful'
      subject.save
      expect(subject.notified_recipients?).to be_truthy
    end
  end
end
