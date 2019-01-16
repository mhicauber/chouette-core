RSpec.describe User, :type => :model do
  # it { should validate_uniqueness_of :email }
  # it { should validate_presence_of :name }

  describe "#destroy" do
    let!(:organisation){create(:organisation)}
    let!(:user){create(:user, :organisation => organisation)}

    context "user's organisation contains many user" do
      let!(:other_user){create(:user, :organisation => organisation)}

      it "should destoy also user's organisation" do
        user.destroy
        expect(Organisation.where(:name => organisation.name).exists?).to be_truthy
        read_organisation = Organisation.where(:name => organisation.name).first
        expect(read_organisation.users.count).to eq(1)
        expect(read_organisation.users.first).to eq(other_user)
      end
    end
  end

  describe '#invite' do
    let(:organisation) { create :organisation }

    it 'should send an email' do
      expect(DeviseMailer).to receive(:invitation_instructions).and_call_original
      expect(DeviseMailer).to_not receive(:confirmation_instructions)
      expect(User.invite(email: 'foo@example.com', name: 'foo', profile: :admin, organisation: organisation).first).to be_falsy
    end

    context 'when the user alredy exists' do
      before(:each) do
        create :user, email: 'foo@example.com', organisation: organisation
      end

      it 'should not send an email' do
        expect(DeviseMailer).to_not receive(:invitation_instructions)
        expect(User.invite(email: 'foo@example.com', name: 'foo', profile: :admin, organisation: organisation).first).to be_truthy
      end
    end
  end

  let(:user) { build :user, permissions: [] }
  describe '#profile' do
    it 'should be :custom by default' do
      expect(user.profile).to eq :custom
    end

    it 'should match the given profiles' do
      Permission::Profile.each do |profile|
        user.profile = profile
        expect(user.profile).to eq profile
        expect(user.permissions).to eq Permission::Profile.permissions_for(profile)
        user.permissions.pop
        expect(user.profile).to eq :custom
      end
    end
  end

  describe '#with_states' do
    let(:pending)   { create :user, confirmed_at: nil, invitation_sent_at: nil, locked_at: nil }
    let(:invited)   { create :user, confirmed_at: Time.now, invitation_sent_at: Time.now, invitation_accepted_at: nil, locked_at: nil }
    let(:confirmed) { create :user, confirmed_at: Time.now, invitation_sent_at: Time.now, invitation_accepted_at: Time.now, locked_at: nil }
    let(:other_confirmed) { create :user, confirmed_at: Time.now, invitation_sent_at: nil, invitation_accepted_at: nil, locked_at: nil }
    let(:blocked)   { create :user, confirmed_at: nil, invitation_sent_at: nil, locked_at: Time.now }

    it 'should find correct states' do
      expect(pending.state).to eq :pending
      expect(invited.state).to eq :invited
      expect(confirmed.state).to eq :confirmed
      expect(other_confirmed.state).to eq :confirmed
      expect(blocked.state).to eq :blocked
    end

    it 'should match correct users' do
      expect(User.with_states(:pending)).to match_array [pending]
      expect(User.with_states(:invited)).to match_array [invited]
      expect(User.with_states(:confirmed)).to match_array [confirmed, other_confirmed]
      expect(User.with_states(:blocked)).to match_array [blocked]
      expect(User.with_states(:pending, :invited)).to match_array [pending, invited]
      expect(User.with_states(:invited, :invited)).to match_array [invited]
    end
  end

  describe '#with_profiles' do
    let(:admin)   { create :user, profile: :admin, name: :admin }
    let(:visitor) { create :user, profile: :visitor, name: :visitor }
    let(:editor)  { create :user, profile: :editor, name: :editor }
    let(:custom)  { create :user, profile: :admin, name: :admin }

    before(:each) do
      custom.permissions.pop
      custom.save!
    end

    it 'should match correct users' do
      expect(User.with_profiles(:admin)).to match_array [admin]
      expect(User.with_profiles(:visitor)).to match_array [visitor]
      expect(User.with_profiles(:admin, :visitor)).to match_array [admin, visitor]
      expect(User.with_profiles(:admin, :custom)).to match_array [admin, custom]
      expect(User.with_profiles(:custom)).to match_array [custom]
    end
  end
end
