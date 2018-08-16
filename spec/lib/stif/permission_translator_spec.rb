# coding: utf-8
RSpec.describe Stif::PermissionTranslator do

  context "No SSO Permissions" do
    it { expect(described_class.translate([])).to be_empty  }
  end

  context "SSO Permission boiv:read-offer →" do

    it "sessions.create only" do
      expect( described_class.translate(%w{boiv:read-offer}) ).to eq(%w{sessions.create})
    end

    it "sessions.create only" do
      expect( described_class.translate(%w{boiv:read-offer}.to_json) ).to eq(%w{sessions.create})
    end

  end

  context "SSO Permission boiv:edit-offer →" do

    it "all permissions" do
      expect( described_class.translate(%w{boiv:edit-offer}) ).to match_array(Support::Permissions.all_permissions)
    end

    it "all permissions, no doubletons" do
      expect( described_class.translate(%w{boiv:edit-offer boiv:read-offer}) ).to match_array(Support::Permissions.all_permissions)
    end

    it "all permissions, input order agnostic" do
      expect( described_class.translate(%w{boiv:read-offer boiv:edit-offer}) ).to match_array(Support::Permissions.all_permissions)
    end
  end

  context "SSO Permission ignores garbage (no injection) →" do
    it "remains empty" do
      expect( described_class.translate(%w{referentials.create}) ).to be_empty
    end

    it "remains at boiv:read-offer level" do
      expect( described_class.translate(%w{referentials.create boiv:read-offer calendars.delete}) ).to eq(%w{sessions.create})
    end

    it "does not add garbage or doubletons for boiv:edit-offer level" do
      expect(
        described_class.translate(%w{xxx boiv:read-offer lines.delete boiv:edit-offer footnotes.update})
      ).to match_array(Support::Permissions.all_permissions)
    end
  end

  context "For the STIF organisation" do
    let(:organisation){ build_stubbed :organisation, name: "STIF" }
    let(:permissions){ %w{calendars.share stop_area_referentials.synchronize line_referentials.synchronize}.sort }
    it "adds the STIF permission" do
      expect(described_class.translate([], organisation).sort).to eq permissions
    end

    context "with the case changed" do
      let(:organisation){ build_stubbed :organisation, name: "StiF" }
      it "adds the STIF permission" do
        expect(described_class.translate([], organisation).sort).to eq permissions
      end
    end
  end
end
