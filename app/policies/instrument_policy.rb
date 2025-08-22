class InstrumentPolicy < ApplicationPolicy
  def index?
    true # Anyone can view instruments
  end
  
  def show?
    true # Anyone can view an instrument
  end
  
  def create?
    user&.can_list_instruments?
  end
  
  def new?
    create?
  end
  
  def update?
    user == record.owner || user&.admin?
  end
  
  def edit?
    update?
  end
  
  def destroy?
    user == record.owner || user&.admin?
  end
  
  def toggle_availability?
    update?
  end
  
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.owner?
        scope.where(owner: user).or(scope.available)
      else
        scope.available
      end
    end
  end
end