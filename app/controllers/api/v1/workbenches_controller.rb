class Api::V1::WorkbenchesController < Api::V1::WorkbenchController
  defaults resource_class: Workbench

  protected

  def begin_of_association_chain
  end
end
