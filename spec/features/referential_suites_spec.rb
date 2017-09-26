RSpec.describe 'ReferentialSuites', type: :feature do

  login_user

  let(:workbench) { create :workbench }
  let!(:referential_suite) { create :referential_suite }

  describe 'index' do
    before(:each) { visit workbench_output_path(workbench) }

    it 'has a page with the correct information' do
      # Breadcrumb
      expect( page ).to have_text('Accueil')
      expect( page ).to have_text("Gestion de l'offre")
      # Title
      expect( page ).to have_text('Offres de mon organisation')
    end

  end
end
