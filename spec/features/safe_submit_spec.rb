RSpec.describe 'SafeSubmit', type: :feature do
  login_user

  let(:workbench) { create :workbench, organisation: @user.organisation }
  let(:path){ new_workbench_api_key_path(workbench) }

  with_permissions 'api_keys.create' do
    it 'view shows the corresponding buttons' do
      visit path
      expect(page).to have_css('input[type=submit][data-disable-with]')
    end
  end
end
