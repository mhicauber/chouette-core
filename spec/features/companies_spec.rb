# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Companies", :type => :feature do
  login_user

  let(:line_referential) { create :line_referential, member: @user.organisation }
  let!(:companies) { Array.new(2) { create :company, line_referential: line_referential } }
  subject { companies.first }

  describe "index" do
    before(:each) { visit line_referential_companies_path(line_referential) }

    it "displays companies" do
      expect(page).to have_content(companies.first.name)
      expect(page).to have_content(companies.last.name)
    end

    context 'filtering' do
      it 'supports filtering by name' do
        fill_in 'q[name_or_short_id_cont]', with: companies.first.name
        click_button 'search-btn'
        expect(page).to have_content(companies.first.name)
        expect(page).not_to have_content(companies.last.name)
      end

      it 'supports filtering by objectid' do
        fill_in 'q[name_or_short_id_cont]', with: companies.first.get_objectid.short_id
        click_button 'search-btn'
        expect(page).to have_content(companies.first.name)
        expect(page).not_to have_content(companies.last.name)
      end
    end
  end

  describe "show" do
    it "displays line" do
      visit line_referential_company_path(line_referential, companies.first)
      expect(page).to have_content(companies.first.name)
    end
  end

  # describe "show" do
  #   it "display company" do
  #     visit line_referential_companies_path(line_referential)
  #     expect(page).to have_content(companies.first.name)
  #   end
  #
  # end

  # Fixme 1780
  # describe "new" do
  #   it "creates company and return to show" do
  #     visit line_referential_companies_path(line_referential)
  #     click_link "Ajouter un transporteur"
  #     fill_in "company_name", :with => "Company 1"
  #     fill_in "Numéro d'enregistrement", :with => "test-1"
  #     fill_in "Identifiant Neptune", :with => "chouette:test:Company:1"
  #     click_button("Créer transporteur")
  #     expect(page).to have_content("Company 1")
  #   end
  # end

  # describe "edit and return to show" do
  #   it "edit company" do
  #     visit line_referential_company_path(line_referential, subject)
  #     click_link "Editer ce transporteur"
  #     fill_in "company_name", :with => "Company Modified"
  #     fill_in "Numéro d'enregistrement", :with => "test-1"
  #     click_button("Editer transporteur")
  #     expect(page).to have_content("Company Modified")
  #   end
  # end

end
