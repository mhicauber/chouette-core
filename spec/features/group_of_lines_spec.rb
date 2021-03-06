# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Group of lines", :type => :feature do
  login_user

  let!(:network) { create(:network) }
  let!(:company) { create(:company) }
  let!(:line) { create(:line_with_stop_areas, :network => network, :company => company) }
  let!(:group_of_lines) { Array.new(2) { create(:group_of_line, line_referential: line_referential) } }
  subject { group_of_lines.first }

  let(:line_referential) { create :line_referential, member: @user.organisation }

  before :each do
    subject.lines << line
  end

  describe "index" do
    before(:each) { visit line_referential_group_of_lines_path(line_referential) }

    it "displays groups of lines" do
      expect(page).to have_content(group_of_lines.first.name)
      expect(page).to have_content(group_of_lines.last.name)
    end

    context 'filtering' do
      it 'supports filtering by name' do
        fill_in 'q[name_cont]', with: group_of_lines.first.name
        click_button 'search-btn'
        expect(page).to have_content(group_of_lines.first.name)
        expect(page).not_to have_content(group_of_lines.last.name)
      end
    end
  end

  describe "show" do
    it "displays group of line" do
      visit line_referential_group_of_lines_path(line_referential)
      click_link subject.name
      expect(page).to have_content(subject.name)
    end
  end

  # Fixme #1780
  # describe "new" do
  #   it "creates group of line and return to show" do
  #     visit line_referential_group_of_lines_path(line_referential)
  #     click_link I18n.t('group_of_lines.actions.new')
  #     fill_in "group_of_line[name]", :with => "Group of lines 1"
  #     fill_in "group_of_line[registration_number]", :with => "1"
  #     fill_in "group_of_line[objectid]", :with => "chouette:test:GroupOfLine:999"
  #     click_button(I18n.t('formtastic.create',model: I18n.t('activerecord.models.group_of_line.one')))
  #     expect(page).to have_content("Group of lines 1")
  #   end
  # end

  # describe "edit and return to show" do
  #   it "edit line" do
  #     visit line_referential_group_of_line_path(line_referential, subject)
  #     click_link I18n.t('group_of_lines.actions.edit')
  #     fill_in "group_of_line[name]", :with => "Group of lines Modified"
  #     fill_in "group_of_line[registration_number]", :with => "test-1"
  #     click_button(I18n.t('formtastic.update',model: I18n.t('activerecord.models.group_of_line.one')))
  #     expect(page).to have_content("Group of lines Modified")
  #   end
  # end

end
