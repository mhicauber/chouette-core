RSpec.describe 'New API Key', type: :feature do
  login_user

  describe "api_keys#destroy" do

    let!( :api_key ){ create :api_key, name: SecureRandom.uuid, organisation: @user.organisation }

    let( :edit_label ){ "#{api_key.name} : #{api_key.token}" }
    let( :destroy_label ){ "Supprimer" }

    xit 'complete workflow' do
      # /workbenches
      visit dashboard_path
      # the api_key is visible
      click_link edit_label

      # brings us to correct page
      expect(page.current_path).to eq(edit_api_key_path(api_key))
      expect(page).to have_content("Supprimer")
      # click_link(destroy_label)

      # # check impact on DB
      # expect(ApiKey.where(id: api_key.id)).to be_empty

      # # check redirect and changed display
      # expect(page.current_path).to eq(dashboard_path)
      # # deleted api_key's not shown anymore
      # expect( page ).not_to have_content(edit_label)
    end

  end

end
