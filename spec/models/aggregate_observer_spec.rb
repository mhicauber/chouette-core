require 'rails_helper'

RSpec.describe MergeObserver, type: :observer do
  let(:user) {create :user}
  let(:workbench){ create :workbench }
  let(:ref1) { create :referential, workbench: workbench, organisation: workbench.organisation }
  let(:ref2) { create :referential, workbench: workbench, organisation: workbench.organisation }

  let(:aggregate) { Aggregate.create(workgroup: referential.workgroup, referentials: [ref1, ref2], creator: user.name) }
 
  context "when notifications are disabled" do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( false )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_falsy
    end

    it 'should not schedule mailer' do
      aggregate.status = 'successful'
      aggregate.save
      expect(MailerJob).to_not receive(:perform_later).with 'AggregateMailer', 'finished', anything
    end  

  end

  context 'when notifications are enabled' do
    before(:each) do
      allow(Rails.configuration)
        .to receive(:enable_subscriptions_notifications)
        .and_return( true )

      expect(Rails.configuration.enable_subscriptions_notifications).to be_truthy
    end
    it 'should observe aggregate finish' do
      expect(AggregateObserver.instance).to receive(:after_update)
      aggregate.status = 'successful'
      aggregate.save
    end

    xit 'should schedule mailer on aggregate finish' do
      expect(MailerJob).to receive(:perform_later).with 'AggregateMailer', 'finished', anything
      aggregate.status = 'successful'
      aggregate.save
    end
  end
end
