class ReviewPolicy < ApplicationPolicy
  def create?
    return false unless user.present? && record.rental.present?
    
    record.rental.can_be_reviewed_by?(user) && !record.rental.reviewed_by?(user)
  end
  
  def new?
    create?
  end
  
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end