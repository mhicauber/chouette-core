class Aggregate < ActiveRecord::Base
  include OperationSupport

  belongs_to :workgroup

  validates :workgroup, presence: true

  def clean_scope
    workgroup.aggregates
  end
end
