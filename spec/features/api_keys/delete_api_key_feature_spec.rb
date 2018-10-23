RSpec.describe 'New API Key', type: :feature do
  login_user

  with_permissions 'api_keys.index' do
    describe "api_keys#destroy" do
      let(:workbench) { @user.organisation.workbenches.first }
      let!(:api_key){ create :api_key, name: SecureRandom.uuid, workbench: workbench }

      let(:destroy_label){ "Supprimer" }

      it 'complete workflow' do
        # /workbenches/1/api_keys
        visit workbench_api_keys_path(workbench)

        # the api_key is visible
        expect(page).to have_content(api_key.token)

        find(".dropdown-toggle").click
        click_link destroy_label

        expect(page.current_path).to eq(workbench_api_keys_path(workbench))
        expect(page).to have_content("Aucune")
      end
    end
  end
end
