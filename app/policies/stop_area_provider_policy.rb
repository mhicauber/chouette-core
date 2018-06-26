class StopAreaProviderPolicy < ApplicationPolicy

  def update?
    update_stop_area_referential?
  end

  def edit?
    update?
  end

  def destroy?
    update_stop_area_referential?
  end

  def update_stop_area_referential?
    StopAreaReferentialPolicy.new(@user_context, @record.stop_area_referential).synchronize?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
