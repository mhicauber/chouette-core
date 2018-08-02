# coding: utf-8
class Organisation < ApplicationModel
  include DataFormatEnumerations

  has_many :users, dependent: :destroy
  has_many :referentials, dependent: :destroy
  has_many :compliance_control_sets, dependent: :destroy

  has_many :stop_area_referential_memberships, dependent: :destroy
  has_many :stop_area_referentials, through: :stop_area_referential_memberships

  has_many :line_referential_memberships, dependent: :destroy
  has_many :line_referentials, through: :line_referential_memberships

  has_many :workbenches, dependent: :destroy
  has_many :workgroups, through: :workbenches

  has_many :calendars, dependent: :destroy
  has_many :api_keys, class_name: 'Api::V1::ApiKey'

  validates_presence_of :name
  validates_uniqueness_of :code

  def find_referential(referential_id)
    organisation_referential = referentials.find_by id: referential_id
    return organisation_referential if organisation_referential

    # TODO: Replace each with find
    workbenches.each do |workbench|
      workbench_referential = workbench.all_referentials.find_by id: referential_id
      return workbench_referential if workbench_referential
    end

    raise ActiveRecord::RecordNotFound
  end

  def functional_scope
    JSON.parse( (sso_attributes || {}).fetch('functional_scope', '[]') )
  end

  def lines_set
    STIF::CodifligneLineId.lines_set_from_functional_scope( functional_scope )
  end

  def has_feature?(feature)
    features && features.include?(feature.to_s)
  end

  def default_workbench
    workbenches.default
  end

  def lines_scope
    functional_scope = sso_attributes.try(:[], "functional_scope")
    JSON.parse(functional_scope) if functional_scope
  end
end
