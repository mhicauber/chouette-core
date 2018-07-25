RSpec.describe 'Edit API Key', type: :feature do
  login_user

  describe "api_keys#edit" do
    let(:workbench) { @user.organisation.workbenches.first }
    let!(:api_key){ create :api_key, name: SecureRandom.uuid, workbench: workbench }

    let(:name_label){ "Nom" }
    let(:validate_label){ "Valider" }

    let(:unique_name){ SecureRandom.uuid }

    let(:edit_label) { "Editer" }

    it 'complete workflow' do
      skip "Specific to STIF Dashboard" if Dashboard.default_class != Stif::Dashboard

      # /workbenches/1/api_keys
      visit workbench_api_keys_path(workbench)

      # the api_key is visible
      expect(page).to have_content(api_key.name)

      find(".dropdown-toggle").click
      click_link edit_label

      # brings us to correct page
      expect(page.current_path).to eq(edit_workbench_api_key_path(workbench, api_key))
      fill_in(name_label, with: unique_name)
      click_button(validate_label)

      # check impact on DB
      expect(api_key.reload.name).to eq(unique_name)

      # check redirect and changed display
      expect(page.current_path).to eq(workbench_api_keys_path(workbench))
      # changed api_key's name exists now
      expect(page).to have_content(unique_name)
    end
  end
end
