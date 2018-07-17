# coding: utf-8
RSpec.describe 'New API Key', type: :feature do
  login_user

  describe "api_keys#create" do

    let( :create_label ){ "Créer une clé d'API" }
    let( :name_label ){ "Nom" }
    let( :validate_label ){ "Valider" }

    let( :unique_name ){ SecureRandom.uuid }
    let( :last_api_key ){ ApiKey.last }


    it 'complete workflow' do
      skip "Specific to STIF Dashboard" if Dashboard.default_class != Stif::Dashboard

      # /workbenches
      visit dashboard_path
      expect(page).to have_link(create_label, href: new_api_key_path)
      # to be created api_key does not exist yet
      expect( page ).not_to have_content(unique_name)

      # /api_keys/new
      click_link create_label
      fill_in(name_label, with: unique_name)
      click_button validate_label

      # check impact on DB
      expect(last_api_key.name).to eq(unique_name)

      # check redirect and changed display
      expect(page.current_path).to eq(dashboard_path)
      # to be created api_key exists now
      expect( page ).to have_content(unique_name)
    end

  end

end
