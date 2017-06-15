require 'spec_helper'
require 'htmlbeautifier'

module TableBuilderHelper
  include Pundit
end

describe TableBuilderHelper, type: :helper do
  describe "#table_builder_2" do
    it "builds a table" do
      referential = build_stubbed(:referential)
      workbench = referential.workbench

      # user_context = create_user_context(
      #   user: build_stubbed(:user),
      #   referential: referential
      # )
      user_context = OpenStruct.new(
        user: build_stubbed(
          :user,
          organisation: referential.organisation,
          permissions: [
            'referentials.create',
            'referentials.edit',
            'referentials.destroy'
          ]
        ),
        context: { referential: referential }
      )
      allow(helper).to receive(:current_user).and_return(user_context)

      referentials = [referential]

      allow(referentials).to receive(:model).and_return(Referential)

      allow(helper).to receive(:params).and_return({
        controller: 'workbenches',
        action: 'show',
        id: referentials[0].workbench.id
      })

      referentials = ModelDecorator.decorate(
        referentials,
        with: ReferentialDecorator
      )

      expected = <<-HTML
<table class="table has-filter has-search">
    <thead>
        <tr>
            <th>
                <div class="checkbox"><input type="checkbox" name="0" id="0" value="all" /><label for="0"></label></div>
            </th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=name">Nom<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=status">Etat<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=organisation">Organisation<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=validity_period">Période de validité englobante<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=lines">Lignes<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=created_at">Créé le<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=updated_at">Edité le<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/workbenches/#{workbench.id}?direction=desc&amp;sort=published_at">Intégré le<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <div class="checkbox"><input type="checkbox" name="#{referential.id}" id="#{referential.id}" value="#{referential.id}" /><label for="#{referential.id}"></label></div>
            </td>
            <td title="Voir"><a href="/referentials/#{referential.id}">#{referential.name}</a></td>
            <td>
                <div class='td-block'><span class='sb sb-lg sb-preparing'></span><span>En préparation</span></div>
            </td>
            <td>#{referential.organisation.name}</td>
            <td>-</td>
            <td>#{referential.lines.count}</td>
            <td>#{I18n.localize(referential.created_at, format: :short)}</td>
            <td>#{I18n.localize(referential.updated_at, format: :short)}</td>
            <td></td>
            <td class="actions">
                <div class="btn-group">
                    <div class="btn dropdown-toggle" data-toggle="dropdown"><span class="fa fa-cog"></span></div>
                    <ul class="dropdown-menu">
                        <li><a href="/referentials/#{referential.id}">Consulter</a></li>
                        <li><a href="/referentials/#{referential.id}/edit">Editer</a></li>
                        <li><a href="/referentials/1008/time_tables">Calendriers</a></li>
                        <li><a href="/referentials/new?from=1008">Dupliquer</a></li>
                        <li><a rel="nofollow" data-method="put" href="/referentials/#{referential.id}/archive">Conserver</a></li>
                        <li class="delete-action"><a data-confirm="Etes-vous sûr(e) de vouloir effectuer cette action ?" rel="nofollow" data-method="delete" href="/referentials/#{referential.id}"><span class="fa fa-trash"></span>Supprimer</a></li>
                    </ul>
                </div>
            </td>
        </tr>
    </tbody>
</table>
      HTML
# TODO: Create a module for the selection box
# <div class="select_toolbox noselect">
#     <ul>
#         <li class="st_action"><a data-path="/workbenches/1/referentials" data-confirm="Etes-vous sûr(e) de vouloir effectuer cette action ?" title="Supprimer" rel="nofollow" data-method="delete" href="#"><span class="fa fa-trash"></span></a></li>
#     </ul><span class="info-msg"><span>0</span> élément(s) sélectionné(s)</span>
# </div>

      html_str = helper.table_builder_2(
        referentials,
        [
          TableBuilderHelper::Column.new(
            key: :name,
            attribute: 'name'
          ),
          TableBuilderHelper::Column.new(
            key: :status,
            attribute: Proc.new do |w|
              if w.archived?
                ("<div class='td-block'><span class='fa fa-archive'></span><span>Conservé</span></div>").html_safe
              else
                ("<div class='td-block'><span class='sb sb-lg sb-preparing'></span><span>En préparation</span></div>").html_safe
              end
            end
          ),
          TableBuilderHelper::Column.new(
            key: :organisation,
            attribute: Proc.new {|w| w.organisation.name}
          ),
          TableBuilderHelper::Column.new(
            key: :validity_period,
            attribute: Proc.new do |w|
              if w.validity_period.nil?
                '-'
              else
                t(
                  'validity_range',
                  debut: l(w.try(:validity_period).try(:begin), format: :short),
                  end: l(w.try(:validity_period).try(:end), format: :short)
                )
              end
            end
          ),
          TableBuilderHelper::Column.new(
            key: :lines,
            attribute: Proc.new {|w| w.lines.count}
          ),
          TableBuilderHelper::Column.new(
            key: :created_at,
            attribute: Proc.new {|w| l(w.created_at, format: :short)}
          ),
          TableBuilderHelper::Column.new(
            key: :updated_at,
            attribute: Proc.new {|w| l(w.updated_at, format: :short)}
          ),
          TableBuilderHelper::Column.new(
            key: :published_at,
            attribute: ''
          )
        ],
        selectable: true,
        links: [:show, :edit],
        cls: 'table has-filter has-search'
      )

      beautified_html = HtmlBeautifier.beautify(html_str, indent: '    ')

      expect(beautified_html).to eq(expected.chomp)
    end

    it "can set a column as non-sortable" do
      company = build_stubbed(:company)
      line_referential = build_stubbed(
        :line_referential,
        companies: [company]
      )
      referential = build_stubbed(
        :referential,
        line_referential: line_referential
      )

      user_context = OpenStruct.new(
        user: build_stubbed(
          :user,
          organisation: referential.organisation,
          permissions: [
            'referentials.create',
            'referentials.edit',
            'referentials.destroy'
          ]
        ),
        context: { referential: referential }
      )
      allow(helper).to receive(:current_user).and_return(user_context)
      allow(TableBuilderHelper::URL).to receive(:current_referential)
        .and_return(referential)

      companies = [company]

      allow(companies).to receive(:model).and_return(Chouette::Company)

      allow(helper).to receive(:params).and_return({
        controller: 'referential_companies',
        action: 'index',
        referential_id: referential.id
      })

      companies = ModelDecorator.decorate(
        companies,
        with: CompanyDecorator
      )

      expected = <<-HTML
<table class="table has-search">
    <thead>
        <tr>
            <th>ID Codif</th>
            <th><a href="/referentials/#{referential.id}/companies?direction=desc&amp;sort=name">Nom<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/referentials/#{referential.id}/companies?direction=desc&amp;sort=phone">Numéro de téléphone<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/referentials/#{referential.id}/companies?direction=desc&amp;sort=email">Email<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th><a href="/referentials/#{referential.id}/companies?direction=desc&amp;sort=url">Page web associée<span class="orderers"><span class="fa fa-sort-asc active"></span><span class="fa fa-sort-desc "></span></span></a></th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>#{company.objectid.local_id}</td>
            <td title="Voir"><a href="/referentials/#{referential.id}/companies/#{company.id}">#{company.name}</a></td>
            <td></td>
            <td></td>
            <td></td>
            <td class="actions">
                <div class="btn-group">
                    <div class="btn dropdown-toggle" data-toggle="dropdown"><span class="fa fa-cog"></span></div>
                    <ul class="dropdown-menu">
                        <li><a href="/referentials/#{referential.id}/companies/#{company.id}">Consulter</a></li>
                    </ul>
                </div>
            </td>
        </tr>
    </tbody>
</table>
      HTML

      html_str = helper.table_builder_2(
        companies,
        [
          TableBuilderHelper::Column.new(
            name: 'ID Codif',
            attribute: Proc.new { |n| n.try(:objectid).try(:local_id) },
            sortable: false
          ),
          TableBuilderHelper::Column.new(
            key: :name,
            attribute: 'name'
          ),
          TableBuilderHelper::Column.new(
            key: :phone,
            attribute: 'phone'
          ),
          TableBuilderHelper::Column.new(
            key: :email,
            attribute: 'email'
          ),
          TableBuilderHelper::Column.new(
            key: :url,
            attribute: 'url'
          ),
        ],
        links: [:show, :edit, :delete],
        cls: 'table has-search'
      )

      beautified_html = HtmlBeautifier.beautify(html_str, indent: '    ')

      expect(beautified_html).to eq(expected.chomp)
    end
  end
end


# Replace table builder on workspaces#show page
# Make the builder work without a `current_referential` so we can actually test it
# Make a way to define a column as non-sortable. By default, columns will be sortable. Unless sortable==false and no columns should be sortable.
#
#
# TODO:
# - Finish writing workbench test
# - Port some code over to the new table builder
# - Ask Jean-Paul if there's anything he wishes could be changed or improved about the existing table builder
# - Thing that Jean-Paul didn't like was the link generation
