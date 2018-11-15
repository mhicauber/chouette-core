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

    context "opeations that belong to user" do
      let!(:import) { create :import,  user: user}
      let!(:export) { create :export, user: user, type: 'Export::Gtfs' }
      let!(:ccset) { create :compliance_check_set, user: user }
      let(:workbench) { create :workbench, organisation: user.organisation }
      let(:ref1) {create :referential, workbench: workbench, organisation: user.organisation}
      let(:ref2) {create :referential, workbench: workbench, organisation: user.organisation}
      let!(:merge) { create :merge, user: user, referential_ids: [ref1.id] }
      let!(:aggregate) { Aggregate.create(workgroup: workbench.workgroup, referentials: [ref1, ref2], user: user) }

      it "should nullify their #user_id" do
        user.destroy
        [import, export, ccset, merge, aggregate].each { |operation| expect(operation.reload.user_id).to be_nil }
      end
    end
  end
end
