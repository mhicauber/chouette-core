RSpec.describe Version do

  subject{ Version.current }

  let(:git_branch_name){ nil }
  let(:git_commit_name){ nil }
  let(:version_file){ nil }
  before(:each) do
    Version.reset
    allow(Version).to receive(:get_branch_name).and_return(git_branch_name)
    allow(Version).to receive(:get_commit_name).and_return(git_commit_name)
    allow(Version).to receive(:read_version_file).and_return(version_file)
  end

  it { should be_nil }

  context "with a valid version.yml" do
    let(:version_file){ read_fixture('valid_version.json') }

    it "should read config/version.yml" do
      expect(subject).to eq "Toto"
    end

    context "with a git version" do
      let(:git_branch_name){ "master" }
      let(:git_commit_name){ "chief" }
      it "should ignore the git version" do
        expect(subject).to eq "Toto"
      end
    end
  end

  context "with a invalid version.yml" do
    let(:version_file){ read_fixture('invalid_version.json') }

    it "should be nil" do
      expect(subject).to be_nil
    end

    context "with a git version" do
      let(:git_branch_name){ "master" }
      let(:git_commit_name){ "chief" }
      it "should use the git version" do
        expect(subject).to eq "master chief"
      end
    end

    context "with an invalid git version" do
      let(:git_commit_name){ "chief" }
      it "should be nil" do
        expect(subject).to be_nil
      end
    end
  end
end
